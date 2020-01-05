module ReleaseNotes
  def current_release_notes
    tag_name = data.releases.latest.tag_name

    unless tag_name =~ /\A(v\d+\.\d+)/
      raise "Cannot extract minor version (vX.X) from tag name %s" % tag_name
    end

    sitemap.find_resource_by_path "/release-notes/#{$1}.html"
  end

  def all_release_notes
    sitemap.resources
      .select {|page| page.path.start_with? 'release-notes/' }
      .sort_by {|p| Gem::Version.new p.data.version }
  end

  def format_release_notes(release_notes)
    release_notes = release_notes.to_str

    release_notes.gsub!(/\[(([tp])=(\d+))\]/) {
      title = $2 == 't' ? "Forum thread \##{$3}" : "Forum post \##{$3}"
      yield title, "https://forum.cockos.com/showthread.php?#{$1}"
    }

    release_notes.gsub!(/\[#(\d+)\]/) {
      yield "GitHub issue \##{$1}", "https://github.com/cfillion/reapack/issues/#{$1}"
    }

    release_notes
  end
end
