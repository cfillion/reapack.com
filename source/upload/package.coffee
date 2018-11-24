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
    file.providesLine() for file in @files

  header: ->
    header = new Header
    header.push 'description', @name if @name
    header.push 'author', @author if @author
    header.push 'version', @version if @version
    header.push 'changelog', @changelog if @changelog
    header.push 'provides', provides if provides = @providesTag()
    for tag in ['link', 'screenshot', 'donation']
      links = @linkTag tag
      header.push tag, links if links.length > 0
    header.push 'about', @about if @about
    header
