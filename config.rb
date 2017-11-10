require 'slim'

Middleman::Util::EnhancedHash.disable_warnings

activate :asset_hash
activate :autoprefixer
activate :directory_indexes
activate :minify_css
activate :minify_javascript

set :slim, disable_escape: false, use_html_safe: false
set :trailing_slash, false

set :software_requirements, 'REAPER v4.7+ (v5.12 or later recommended).'
set :system_requirements, 'At least macOS 10.7, Windows Vista or Wine 1.8.'

helpers do
  def current_source_file
    root = Pathname.new app.root
    source_file = Pathname.new current_page.source_file
    source_file.relative_path_from root
  end
end
