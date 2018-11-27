import { join, extname } from 'path'
import { NoIndexHeader } from './header'
import * as Types from './types'

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

isIndexable = (matchExt) ->
  for _, type of Types
    for ext in type.extensions
      return true if ext.toLowerCase() == matchExt

  false

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
    @localName = null

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
    { file: @, name: @effectiveStorageName() }

  category: ->
    @package.category || 'Category'

  isBinary: ->
    @content instanceof ArrayBuffer

  setContentFromLocalFile: (localFile) ->
    if localFile.size > (1000 ** 2) * 10
      alert "'#{localFile.name}' is too big to be uploaded to the repository."
      return

    reader = new FileReader()

    reader.onload = =>
      @localName = localFile.name

      if reader.result instanceof ArrayBuffer
        @content = reader.result
      else if reader.result.includes '\0'
        reader.readAsArrayBuffer localFile
      else
        @content = reader.result

    reader.readAsText localFile

  storageDirectory: ->
    segments = [@category()]
    segments.push @defaultName(false) unless @isPackage
    join segments...

  installDirectory: ->
    if @effectiveType().longPath then @storageDirectory() else ''

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

    "#{author}#{pkgName}#{if ext then defaultExt else ''}"

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

  installPath: ->
    root = @effectiveType().installRoot
    filePath = join @installDirectory(), @effectiveInstallName()

    "#{root}/#{filePath}"

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

  providesLine: ->
    return unless @install

    sourceFile = @source.file ? @
    storageName = sourceFile.effectiveStorageName()
    installName = @effectiveInstallName()

    opts = @options()
    line = ''
    line += "[#{opts.join(' ')}] " if opts.length > 0

    if @source == ExternalSource
      line = "#{installName} #{@url}"
    else
      target = if installName != storageName then " > #{installName}" else ''

      if sourceFile.isPackage
        return if opts.length == 0 && !target
        storageName = '.'

      line += "#{storageName}#{target}"

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
