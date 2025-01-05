require 'action_view'
require 'slim'

Middleman::Util::EnhancedHash.disable_warnings

activate :asset_hash
activate :autoprefixer
activate :directory_indexes

configure :build do
  activate :minify_css
  activate :minify_javascript, ignore: /upload/
end

activate :external_pipeline,
  name: :webpack,
  command: [
    "NODE_ENV=#{build? ? 'production' : 'development'}",
    'npx --no webpack',
    server? && '--watch' || nil,
  ].compact.join("\x20"),
  source: ".webpack-build",
  disable_background_execution: build?
ignore '/upload/*'
ignore '/stylesheets/upload-components.css'

set :slim, disable_escape: false, use_html_safe: false
set :sass_assets_paths, ['.webpack-build/stylesheets']
set :trailing_slash, false

set :host, 'https://reapack.com'

page 'errors/*', directory_index: false
page 'release-notes/*', layout: :release_notes_layout
