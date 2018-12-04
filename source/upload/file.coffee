import { join, extname, relative } from 'path'
import { NoIndexHeader } from './header'
import { isIndexable, sanitizeFilename, detectBinary } from './file-utils'

export UploadSource = { icon: 'fa-upload', name: 'Upload' }
export ExternalSource = { icon: 'fa-link', name: 'External' }

export ScriptSections = [
    id: 'main'
    name: 'Main'
  ,
    id: 'midi_editor'
    name: 'MIDI Editor'
  ,
    id: 'midi_inlineeditor'
    name: 'MIDI Inline Editor'
  ,
    id: 'midi_eventlisteditor'
    name: 'MIDI Event List Editor'
  ,
    id: 'mediaexplorer'
    name: 'Media Explorer'
]

export default class File
  constructor: (@storageName, @package, @isPackage = false) ->
    @source = UploadSource
    @type = null
    @installName = ''
    @url = ''
    @platform = ''
    @install = @canInstall()
    @sections = []
    @sections.push @defaultSection() if @isPackage
    @content = ''
    @originName = null

  setSource: (source) ->
    if source == ExternalSource || source.file
      unless @installName
        @installName = @storageName
        @storageName = ''

      @install = @canInstall()
    else if !@storageName
      @storageName = @installName
      @installName = ''

    @source = source

  toSource: ->
    { file: @, name: @displayName() }

  category: ->
    @package.category || 'Category'

  isBinary: ->
    @content instanceof ArrayBuffer

  setContentFromLocalFile: (localFile, cb) ->
    MAX_SIZE_TEXT = 3 * (10**6)
    MAX_SIZE_BINARY = 100 * 1000

    tooBig = -> "'#{localFile.name}' is too big to be uploaded to this repository."

    if localFile.size > MAX_SIZE_TEXT
      cb tooBig() if cb
      return

    reader = new FileReader()

    reader.onload = =>
      @originName = localFile.name

      if reader.result instanceof ArrayBuffer
        @content = reader.result
        cb()
      else if detectBinary reader.result
        if localFile.size > MAX_SIZE_BINARY
          cb tooBig() if cb
        else
          reader.readAsArrayBuffer localFile
      else
        @content = reader.result
        cb()

    reader.readAsText localFile

  authorSlug: ->
    @package.author.toLowerCase().replace /[^\w]+/g, ''

  defaultName: (ext = true) ->
    author = @authorSlug() || 'author'

    if @package.type.noAuthorSlug
      author = ''
    else
      author += '_'

    pkgName = @package.name || 'Package name'
    defaultExt = @package.type.extensions[0]

    sanitizeFilename "#{author}#{pkgName}#{if ext then defaultExt else ''}"

  displayName: ->
    name = if @source == UploadSource
      @effectiveStorageName()
    else
      @effectiveInstallName()

    name || '<no name>'

  storageDirectory: (appendCategory = true) ->
    segments = []
    segments.push @category() if appendCategory
    segments.push @package.storageSubdirectory() unless @isPackage
    join segments...

  installDirectory: ->
    source = @source.file ? @
    source.storageDirectory !!@effectiveType().longPath

  effectiveStorageName: ->
    if @source == UploadSource
      if name = @storageName || (@defaultName() if @isPackage)
        return join name
    ''

  effectiveInstallName: ->
    if name = (@installName || @effectiveStorageName())
      join name
    else
      ''

  effectiveExtname: ->
    extname @effectiveInstallName()

  effectiveType: ->
    @type || @package.type

  # absolute storage path on the repository
  storagePath: ->
    join @storageDirectory(), @effectiveStorageName()

  # installation path relative to the package's category
  installPath: ->
    join @installDirectory(), @effectiveInstallName()

  # installation path relative to the resource directory
  fullInstallPath: ->
    # not using join here to avoid normalizing the path (parsing ..)
    "#{@effectiveType().installRoot}/#{@installPath()}"

  canInstall: ->
    !@isPackage || !@effectiveType().metapackage

  defaultSection: ->
    ScriptSections[switch @category()
      when 'MIDI Editor'
        1
      else
        0
    ]

  isDefaultSection: ->
    @sections.length == 1 && @sections[0] == @defaultSection()

  options: ->
    opts = []
    opts.push @type.type if @type
    opts.push @platform if @platform

    if @effectiveType().actionList
      if @sections.length == 0
        opts.push 'nomain' if @isPackage
      else if @isDefaultSection()
        opts.push 'main' unless @isPackage
      else
        sections = (section.id for section in @sections)
        opts.push "main=#{sections.join ','}"

    opts

  providesLine: (packageFile) ->
    return unless @install

    opts = @options()
    line = ''
    line += "[#{opts.join(' ')}] " if opts.length > 0

    if @source == ExternalSource
      line += "#{@effectiveInstallName()} #{@url}"
    else
      sourceFile = @source.file ? @
      storagePath = relative packageFile.storageDirectory(), sourceFile.storagePath()

      installRoot = packageFile.storageDirectory !!@effectiveType().longPath
      installPath = relative installRoot, @installPath()

      target = if installPath != storagePath then " > #{installPath}" else ''

      if sourceFile.isPackage
        return if opts.length == 0 && !target
        storagePath = '.'

      line += "#{storagePath}#{target}"

    line

  header: ->
    fileext = @effectiveExtname()
    type = @effectiveType()

    header = if @isPackage
      @package.header()
    else if isIndexable(fileext)
      NoIndexHeader

    h = header?.toString(fileext, type)

    if h
      h += '\n' if @content.length > 0
      h
    else
      ''
