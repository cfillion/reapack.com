#!/usr/bin/env ruby

Signal.trap('INT') { abort }

require 'active_support'
require 'active_support/core_ext'
require 'colorize'
require 'fileutils'
require 'json'
require 'nokogiri'
require 'octokit'
require 'open-uri'
require 'yaml'

TaskFailure = Class.new RuntimeError

class Runner
  def initialize
    @root_dir = File.dirname __FILE__
    @config_dir = File.join @root_dir, 'config'
    @data_dir = File.join @root_dir, 'data'

    FileUtils.mkdir_p @data_dir

    @groups = {}
    @failures = 0
  end

  def add(id, klass = nil)
    config = YAML.load_file File.join(@config_dir, "#{id}.yml")

    if klass
      @groups[id] = [klass.new(config)]
    else
      @groups[id] = yield config
    end
  end

  def run(tasks)
    if tasks.empty?
      tasks.concat @groups.keys
    else
      if wrong = tasks.find {|arg| !@groups.has_key? arg }
        $stderr.puts "invalid task '#{wrong}'".red
        $stderr.puts "correct tasks are: #{@groups.keys.join("\x20").bold}"
        return -1
      end
    end

    $stderr.puts "executing tasks #{tasks.join("\x20").bold}\n\n"
    tasks.each {|grp|
      data_file = File.join @data_dir, "#{grp}.yml"
      if File.exist? data_file
        data = Psych.safe_load_file data_file,
                                    permitted_classes: [Symbol, Time],
                                    aliases: true
      end
      @groups[grp].each {|task| data = run_task task, data }
      File.write data_file, data.to_yaml
    }

    $stderr.puts "%s (%d failures)" %
      [@failures > 0 ? 'Done!' : 'Done!'.bold.green, @failures]

    @failures
  end

private
  def run_task(task, data)
    $stderr.puts DateTime.now
    $stderr.puts "#{'->'.blue.bold} Running #{task.inspect}"

    begin
      summary, data = task.run data
      $stderr.puts "   #{'OK!'.green.bold} #{summary}"
    rescue TaskFailure => e
      @failures += 1
      $stderr.puts "   #{'ERR'.red.bold} #{e}"
    end

    $stderr.puts "\n"
    data
  end
end

class Releases
  def initialize(config)
    @config = config
  end

  def inspect
    "GitHub Releases"
  end

  def run(data)
    data ||= {}
    old_dl_count = data[:recent_downloads] || 0

    releases = Octokit.releases @config['github']
    raise TaskFailure, 'no releases' if releases.empty?

    latest = releases.find {|r| !r[:prerelease] }
    latest ||= releases.first
    latest = latest.to_h

    data[:recent_downloads] = releases.map {|release|
      release[:assets].map {|file| file[:download_count] }.inject(&:+).to_i
    }.inject(&:+).to_i

    data[:latest] = latest

    latest[:assets].each {|file|
      if key = @config['files'][file[:name]]
        data[:latest][key] = file
      end
    }

    dl_count_diff = '%+d' % [data[:recent_downloads] - old_dl_count]
    summary = "latest = %s, downloads = %s (all versions, total = %d)" %
      [data[:latest][:name], dl_count_diff.bold.yellow, data[:recent_downloads]]

    [summary, data]
  rescue Faraday::ConnectionFailed, Octokit::Error => e
    raise TaskFailure, e.message
  end
end

class Repo
  def initialize(repo, config)
    @repo = repo
    @config = config
  end

  def inspect
    link = @repo['link']
    Octokit::Repository.from_url(link).slug rescue link
  end

  def run(data)
    name, packages = nil

    URI(@repo['index']).open {|f|
      doc = Nokogiri::XML f.read
      name = doc.root['name'].to_s
      packages = {}

      raise TaskFailure, 'repository is unnamed' if name.empty?

      doc.css('reapack').each do |pkg|
        type = pkg['type']
        type = 'other' unless @config['count_types'].include? type
        packages[type] ||= 0
        packages[type] += 1
      end

      if data.is_a? Array
        data.delete_if {|repo| repo[:index] == @repo['index'] }
      else
        data = []
      end

      data << {
        name: name,
        link: @repo['link'],
        index: @repo['index'],
        disporder: @repo['disporder'],
        builtin: @repo['builtin'] || false,
        featured: @repo['featured'] || false,
        packages: packages,
      }
    }

    summary = "name = %s, packages = %d" %
      [name, packages.map {|k,v| v}.inject(&:+) || 0]

    [summary, data]
  rescue SocketError, OpenURI::HTTPError, Nokogiri::XML::SyntaxError => e
    raise TaskFailure, e.message
  end
end

class CleanupRepos
  def initialize(config)
    @config = config
  end

  def inspect
    'Cleanup repository list'
  end

  def run(data)
    data.keep_if {|data|
      @config['repos'].any? {|repo| repo['index'] == data[:index] }
    }

    data.sort! {|a, b|
      if a[:disporder] && b[:disporder].nil?
        -1
      elsif a[:disporder].nil? && b[:disporder]
        1
      elsif a[:disporder] && b[:disporder]
        a[:disporder] <=> b[:disporder]
      else
        a[:name].downcase <=> b[:name].downcase
      end
    }

    ['Repository list cleaned up.', data]
  end
end

class Donations
  def initialize(config)
    @config = config
  end

  def inspect
    'Monthly donations'
  end

  def run(data)
    client_id, secret = ENV['PAYPAL_CLIENT_ID'], ENV['PAYPAL_SECRET']
    data ||= { goal: 0, progress: 0 }
    return ['SKIPPED: missing credentials', data] unless client_id && secret

    # paranoid, clear credentials before running other tasks
    ENV['PAYPAL_CLIENT_ID'] = ENV['PAYPAL_SECRET'] = nil

    auth_url = URI('https://api.paypal.com/v1/oauth2/token')
    auth_req = Net::HTTP::Post.new auth_url
    auth_req.basic_auth client_id, secret
    auth_req.set_form_data 'grant_type' => 'client_credentials'

    donations_url = URI('https://api.paypal.com/v1/reporting/transactions')
    donations_url.query = URI.encode_www_form \
      start_date: DateTime.now.utc.at_beginning_of_month.iso8601,
      end_date: DateTime.now.utc.at_end_of_month.iso8601,
      transaction_status: 'S',
      fields: 'transaction_info,cart_info'
    donations_req = Net::HTTP::Get.new donations_url

    transactions = Net::HTTP.start(auth_url.host, auth_url.port, use_ssl: true) do |http|
      auth = parse_response http.request auth_req
      donations_req['Authorization'] = "#{auth['token_type']} #{auth['access_token']}"
      parse_response http.request donations_req
    end

    last_refresh = DateTime.parse transactions['last_refreshed_datetime']

    # mismatched currency is not taken into account
    total = transactions['transaction_details'].map do |details|
      tx = Transaction.new details
      tx.amount + tx.fee if tx.amount > 0 && tx.item_name =~ /ReaPack/
    end.compact.sum

    progress = (total / @config['goal']) * 100

    data = {
      goal: @config['goal'],
      progress: [progress, 100].min,
    }

    status = '$%.2f - %s%% towards $%s per month goal (refreshed at %s)' %
      [total, data[:progress], data[:goal], last_refresh.rfc2822]

    [status, data]
  end

  def parse_response(res)
    data = JSON.parse res.body

    unless res.class == Net::HTTPOK
      raise TaskFailure, "#{res.code} #{res.message} #{data}"
    end

    data
  rescue JSON::ParserError => e
    raise TaskFailure, "JSON parser error: #{e.message}"
  end

  class Transaction
    def initialize(tx)
      @tx = tx
    end

    def amount
      @amount ||= @tx.dig('transaction_info', 'transaction_amount', 'value').to_f
    end

    def fee
      @fee ||= @tx.dig('transaction_info', 'fee_amount', 'value').to_f
    end

    def item_name
      @item_name ||= @tx.dig('transaction_info', 'transaction_subject') ||
        @tx.dig('cart_info', 'item_details')&.first&.dig('item_name').to_s
    end
  end
end

runner = Runner.new

runner.add 'donations', Donations
runner.add 'releases', Releases
runner.add 'repos' do |config|
  tasks = config['repos'].map {|repo| Repo.new repo, config }
  tasks << CleanupRepos.new(config)
  tasks
end

exit runner.run ARGV
