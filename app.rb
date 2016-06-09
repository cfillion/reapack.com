require 'em-http'
require 'em-http/middleware/json_response'
require 'filesize'
require 'ostruct'
require 'sass/plugin/rack'
require 'sinatra/base'
require 'time'

Sass::Plugin.options.merge! \
  sourcemap: :none,
  style: :compressed

ReaPack = Class.new

class ReaPack::WebApp < Sinatra::Base
  UPDATE_INTERVAL = 24

  URL = 'https://api.github.com/repos/cfillion/reapack/releases/latest'

  def initialize
    @@lastUpdate = Time.new 0
    @@latest = nil
    super
  end

  def make_request
    client = EventMachine::HttpRequest.new URL
    client.use EM::Middleware::JSONResponse
    client.get
  end

  def update
    now = Time.now
    return if @@lastUpdate > now - 3600

    @@lastUpdate = now

    req = make_request
    req.errback {
    }

    req.callback {
      next unless req.response_header.status == 200
      @@latest = make_release req.response
    }

    nil
  end

  def make_release(json)
    release = OpenStruct.new
    release.url = json['html_url'].to_s
    release.name = json['tag_name'].to_s
    release.author = json['author'].to_h['login'].to_s
    release.time = DateTime.rfc3339 json['published_at']

    json['assets'].to_a.each {|asset|
      case asset['name']
      when 'reaper_reapack32.dylib'
        release.darwin32 = make_asset asset
      when 'reaper_reapack64.dylib'
        release.darwin64 = make_asset asset
      when 'reaper_reapack32.dll'
        release.win32 = make_asset asset
      when 'reaper_reapack64.dll'
        release.win64 = make_asset asset
      end
    }

    release
  end

  def make_asset(json)
    asset = OpenStruct.new
    asset.url = json['browser_download_url']
    asset.size = Filesize.from('%d B' % json['size'].to_i)

    asset
  end

  use Sass::Plugin::Rack

  get '/' do
    @latest = @@latest or update
    last_modified @@lastUpdate if @latest
    slim :index
  end

  get '/sync', user_agent: /\AGitHub-Hookshot\// do
    update
    content_type 'text/plain'
    'Hello GitHub, refreshing the release feed now...'
  end

  not_found do
    slim :not_found
  end
end
