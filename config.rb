require 'slim'

Middleman::Util::EnhancedHash.disable_warnings

activate :asset_hash
activate :autoprefixer
activate :directory_indexes
activate :minify_css
activate :minify_javascript

set :slim, disable_escape: false, use_html_safe: false
set :trailing_slash, false

helpers do
  def markdown(text)
    Tilt['markdown'].new(context: @app) { text }.render
  end
end
