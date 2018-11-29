import File, { UploadSource, ExternalSource } from './file'
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
    line for file in @files when line = file.providesLine @files[0]

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

  validateName: (errors) ->
    lowerName = @name.toLowerCase()

    if lowerName.startsWith "#{@author.toLowerCase()}_"
      errors.push 'The display name should not contain an author prefix.'

    for ext in @type.extensions
      ext = ext.toLowerCase()

      if lowerName.endsWith ext
        errors.push 'The display name should not contain the file extension.'
        break

  validateVersion: (errors) ->
    unless @version.match /^\d/
      errors.push 'The version number must begin with a number.'

  validateFiles: (errors) ->
    match = @files.findIndex (file) =>
      file.source == UploadSource && !file.effectiveStorageName()
    unless match == -1
      errors.push "One or more hosted files don't have a storage file name."

    match = @files.findIndex (file) => !file.effectiveInstallName()
    unless match == -1
      errors.push "One or more files don't have an installation file name."

    match = @files.findIndex (file) =>
      file.source == ExternalSource && !file.url
    unless match == -1
      errors.push "One or more external files don't have a download URL."

    dups = []
    for file, index in @files
      continue unless file.source == UploadSource

      storagePath = file.storagePath()

      otherIndex = @files.findIndex (otherFile) =>
        otherFile.source == UploadSource &&
          storagePath == otherFile.storagePath()

      if otherIndex != index && dups.indexOf(storagePath) == -1
        dups.push storagePath
        errors.push "More than one files are uploaded as '#{storagePath}'."

  validateAll: ->
    errors = []
    validator.call @, errors for validator in [
      @validateName, @validateVersion, @validateFiles
    ]
    errors
