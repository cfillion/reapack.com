require 'sinatra'

require 'sass/plugin/rack'
use Sass::Plugin::Rack

Sass::Plugin.options.merge! \
  sourcemap: :none,
  style: :compressed

get '/' do
  slim :index
end
