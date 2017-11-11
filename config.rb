require 'slim'

Middleman::Util::EnhancedHash.disable_warnings

activate :asset_hash
activate :autoprefixer
activate :directory_indexes
activate :minify_css
activate :minify_javascript

set :slim, disable_escape: false, use_html_safe: false
set :trailing_slash, false

page "release-notes/*", layout: :release_notes_layout

helpers {
  def release_notes
    sitemap.resources
      .select {|page| page.path.start_with? 'release-notes/' }
      .sort_by {|p| Gem::Version.new p.data.version }
  end
}
