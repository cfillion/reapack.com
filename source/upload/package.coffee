import File from './file'
import Header from './header'

export default class Package
  constructor: (@type) ->
    @name = ''
    @category = ''
    @author = ''
    @about = ''
    @links = []
    @version = ''
    @changelog = ''
    @files = [new File(null, @, true)]

  linkTag: (type) ->
    for link in @links when link.type.tag == type
      if link.name
        "#{link.name} #{link.url}"
      else
        link.url

  providesTag: ->
    line for file in @files when line = file.providesLine()

  header: ->
    header = new Header
    header.push 'description', @name if @name
    header.push 'author', @author if @author
    header.push 'version', @version if @version
    header.push 'changelog', @changelog if @changelog
    header.push 'metapackage' unless @files[0].install || @type.metapackage
    header.push 'provides', @providesTag()
    for tag in ['link', 'screenshot', 'donation']
      header.push tag, @linkTag(tag)
    header.push 'about', @about if @about
    header

  findFilesSourcing: (file) ->
    f for f in @files when f.source.file == file
