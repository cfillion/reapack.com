require 'slim'

Middleman::Util::EnhancedHash.disable_warnings

activate :asset_hash
activate :autoprefixer
activate :directory_indexes

configure :build do
  activate :minify_css
  activate :minify_javascript
end

activate :external_pipeline,
  name: :vuejs,
  command: <<~SH,
    mkdir -p .tmp/dist/stylesheets .tmp/dist/javascripts && \
    NODE_ENV=#{build? ? 'production' : 'development'} \
    `npm bin`/#{build? ? 'browserify' : 'watchify'} --extension .coffee \
    -g envify -t coffeeify -t vueify -p bundle-collapser/plugin \
    -p [ vueify/plugins/extract-css -o .tmp/dist/stylesheets/upload-components.css ] \
    -e source/upload/main.coffee -o .tmp/dist/javascripts/upload.js
  SH
  source: ".tmp/dist",
  disable_background_execution: build?
ignore '/upload/*'
ignore '/stylesheets/upload-components.css'

set :slim, disable_escape: false, use_html_safe: false
set :sass_assets_paths, ['.tmp/dist/stylesheets']
set :trailing_slash, false

set :host, 'https://reapack.com'

page 'errors/*', directory_index: false
page 'release-notes/*', layout: :release_notes_layout
