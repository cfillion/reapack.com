module ReleaseNotes
  def latest_release_notes
    sitemap.find_resource_by_path "/release-notes/#{data.releases.latest.name}.html"
  end

  def all_release_notes
    sitemap.resources
      .select {|page| page.path.start_with? 'release-notes/' }
      .sort_by {|p| Gem::Version.new p.data.version }
  end

  def format_release_notes(release_notes)
    release_notes = release_notes.to_str

    release_notes.gsub!(/\[(([tp])=\d+)\]/) {
      title = $2 == 't' ? 'forum thread' : 'forum post'
      yield title, "https://forum.cockos.com/showthread.php?#{$1}"
    }

    release_notes.gsub!(/\[#(\d+)\]/) {
      yield 'GitHub issue', "https://github.com/cfillion/reapack/issues/#{$1}"
    }

    release_notes
  end
end
