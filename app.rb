require 'action_view'
require 'oj'
require 'rack/coffee'
require 'sass/plugin/rack'
require 'sinatra/base'
require 'time'

Oj.default_options = { time_format: :ruby }

Sass::Plugin.options.merge! \
  sourcemap: :none,
  style: :compressed,
  template_location: 'stylesheets'

ReaPack ||= Class.new

class ReaPack::WebApp < Sinatra::Base
  use Sass::Plugin::Rack
  use Rack::Coffee, cache_compile: true
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper

  def initialize
    @@last_update = Time.new 0
    super
  end

  before do
    path = File.join settings.root, 'tmp', 'data.json'
    last_modified File.mtime(path)

    data = Oj.load File.read(path)

    @latest = data[:latest]
    @repos = data[:repos]
    @downloads = data[:downloads]
  end

  get '/' do
    slim :index
  end

  get '/repos' do
    slim :repos
  end

  post '/sync' do
    if request.user_agent =~ /\AGitHub-Hookshot\//
      now = Time.now
      halt 403 if @@last_update < now - (3600 * 24)

      content_type 'text/plain'

      script = File.join settings.root, 'update.rb'
      EM.system "#{script} releases"
      @@last_update = now

      'Hello GitHub!'
    else
      not_found
    end
  end

  not_found do
    slim :not_found
  end
end
