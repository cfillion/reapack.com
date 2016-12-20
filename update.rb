#!/usr/bin/env ruby

Signal.trap('INT') { abort }

require 'colorize'
require 'fileutils'
require 'nokogiri'
require 'octokit'
require 'oj'
require 'open-uri'
require 'time'
require 'yaml'

Oj.default_options = { time_format: :ruby }
String.disable_colorization = !STDOUT.tty? || !STDERR.tty?

GITHUB_PROJECT = 'cfillion/reapack'

FILES = {
  'reaper_reapack32.dylib' => :darwin32,
  'reaper_reapack64.dylib' => :darwin64,
  'reaper_reapack32.dll'   => :win32,
  'reaper_reapack64.dll'   => :win64,
}.freeze

PKG_TYPES = [
  :script,
  :effect,
  :theme,
  :extension,
  :langpack,
].freeze

TaskFailure = Class.new RuntimeError

class Runner
  def initialize
    @root_dir = File.dirname __FILE__
    @data_file = File.join @root_dir, 'tmp', 'data.json'
    FileUtils.mkdir_p File.dirname(@data_file)

    @data = File.exist?(@data_file) ? Oj.load(File.read(@data_file)) : {
      downloads: 0,
      repos: [],
    }
    @old_dl_count = @data[:downloads]

    @failure_count = 0
  end

  attr_reader :failure_count

  def repos
    @repos ||= YAML.load_file File.join(@root_dir, 'repos.yml')
  end

  def run(task)
    warn DateTime.now
    warn "#{'->'.blue.bold} Fetching #{task.inspect}"

    begin
      task.fetch
      task.save @data
      warn "   #{'OK!'.green.bold} #{task}"
    rescue TaskFailure => e
      @failure_count += 1
      warn "   #{'ERR'.red.bold} #{e}"
    end

    warn "\n"
  end

  def cleanup_repos
    @data[:repos].keep_if {|data|
      repos.any? {|repo| repo['index'] == data[:index] }
    }
  end

  def save
    warn "Done. %+d downloads!".bold.yellow % [@data[:downloads] - @old_dl_count]
    File.write @data_file, Oj.dump(@data)
  end
end

class Releases
  def inspect
    "GitHub Releases"
  end

  def to_s
    "latest = #{@latest[:name]}, downloads = #{@downloads} (all versions)"
  end

  def fetch
    releases = Octokit.releases GITHUB_PROJECT

    latest = releases.find {|r| !r[:prerelease] }
    latest ||= releases.first

    @latest = {
      name: latest[:tag_name],
      author: latest[:author][:login],
      stable: !latest[:prerelease],
      link: latest[:html_url],
      time: latest[:published_at],
    }

    latest[:assets].each {|file|
      if key = FILES[file[:name]]
        @latest[key] = {
          name: file[:name],
          link: file[:browser_download_url],
          size: file[:size],
        }
      end
    }

    @downloads = releases.map {|release|
      release[:assets].map {|file| file[:download_count] }.inject(&:+).to_i
    }.inject(&:+).to_i
  rescue Octokit::Error => e
    raise TaskFailure, e.message
  end

  def save(data)
    data[:latest] = @latest
    data[:downloads] = @downloads
  end
end

class Repo
  def initialize(params)
    @params = params
  end

  def link
    @params['link']
  end

  def inspect
    Octokit::Repository.from_url(link).slug rescue link
  end

  def to_s
    "name = #{@name}, packages = #{@packages.map {|k,v| v}.inject(&:+) || 0} "
  end

  def fetch
    open(URI @params['index']) {|f|
      doc = Nokogiri::XML f.read
      @name = doc.root['name'].to_s
      @packages = {}

      return if @name.empty?

      doc.css('reapack').each do |pkg|
        type = pkg['type'].to_sym
        type = :other unless PKG_TYPES.include? type
        @packages[type] ||= 0
        @packages[type] += 1
      end
    }
  rescue OpenURI::HTTPError, Nokogiri::XML::SyntaxError => e
    raise TaskFailure, e.message
  end

  def save(data)
    data[:repos].delete_if {|repo| repo[:index] == @params['index'] }

    data[:repos] << {
      name: @name,
      link: @params['link'],
      index: @params['index'],
      disporder: @params['disporder'],
      default: @params['default'] || false,
      featured: @params['featured'] || false,
      packages: @packages,
    }
    data[:repos].sort! {|a, b|
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
  end
end

runner = Runner.new

tasks = {
  'releases' => [ Releases.new ],
  'repos' => runner.repos.map {|repo| Repo.new(repo) },
}

ARGV.concat tasks.keys if ARGV.empty?

if wrong = ARGV.find {|arg| !tasks.has_key? arg }
  warn "invalid task '#{wrong}'".red
  warn "correct tasks are: #{tasks.keys.join("\x20").bold}"
  exit -1
end

warn "executing tasks #{ARGV.join("\x20").bold}\n\n"
ARGV.each {|arg| tasks[arg].each {|task| runner.run task } }

runner.cleanup_repos
runner.save

exit runner.failure_count
