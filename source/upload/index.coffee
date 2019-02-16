import fuzzysort from 'fuzzysort'
import { relative, extname } from 'path'

import * as Types from './types'
import File, { ExternalSource, ScriptSections } from './file'
import Package, { LinkTypes } from './package'
import { isIndexable, detectBinary } from './file-utils'

resolveType = (typeId) ->
  for _, type of Types
    return type if type.type == typeId

resolveLinkType = (typeId) ->
  for _, type of LinkTypes
    return type if type.rel == typeId

resolveSection = (sectionId) ->
  for _, section of ScriptSections
    return section if section.id == sectionId
  sectionId # fallback

checkedFetch = (url, options = {}) ->
  response = await fetch url, options

  unless response.ok
    throw new Error "Server replied with #{response.status} #{response.statusText}."

  response

class IndexPackage
  constructor: (node, @index) ->
    @fileName = node.getAttribute('name')
    @name = node.getAttribute('desc') || @fileName
    @type = resolveType node.getAttribute('type')
    @category = node.parentNode.getAttribute 'name'
    @linkNodes = node.getElementsByTagName 'link'
    @packageFile = "#{@category}/#{@fileName}"

    @versions = node.getElementsByTagName 'version'
    if verNode = @versions[@versions.length - 1]
      @latest =
        name: verNode.getAttribute 'name'
        author: verNode.getAttribute 'author'
        # Array.from required to prevent odd "Invalid calling object"
        # errors when accessing fileNodes later on Edge (tested on v17).
        fileNodes: Array.from verNode.getElementsByTagName('source')

  isValid: -> @name && @type && @latest

  findVersion: (ver) ->
    for version in @versions
      return version if version.getAttribute('name') == ver

  parseMain: (main) ->
    if main == 'true'
      return [if @category == 'MIDI Editor' then 'midi_editor' else 'main']

    section for sectionId in main.split '\x20' \
      when section = resolveSection sectionId

  parsePlatform: (platform) ->
    if platform == 'all' then '' else platform

  load: ->
    pkg = new Package @type
    pkg.name = @name
    pkg.category = @category

    # for uninstalled package files
    pkg.files[0].storageName = @fileName
    pkg.repoFiles.push @packageFile

    for linkNode in @linkNodes
      type = resolveLinkType(linkNode.getAttribute('rel') || 'website')
      name = linkNode.textContent
      url = linkNode.getAttribute 'href'
      [name, url] = [url, name] unless url
      pkg.links.push { type, name, url } if type && url

    {header, content} = await @fetchFile @packageFile
    pkg.version = header.version || ''
    pkg.author = header.author || ''
    pkg.about = header.about || ''
    pkg.changelog = header.changelog || ''
    pkg.files[0].content = content

    current = @findVersion header.version

    unless current
      throw new Error "Cannot find version '#{header.version}' in the index."

    fileNodes = current.getElementsByTagName 'source'
    await @loadFiles fileNodes, pkg

    pkg

  loadFiles: (fileNodes, pkg) ->
    hosted = {}
    hostedPrefix = "https://github.com/#{@index.repo}/raw/"

    for fileNode in fileNodes
      if fileNode.textContent.startsWith hostedPrefix
        fullPath = fileNode.textContent.substring \
          fileNode.textContent.indexOf('/', hostedPrefix.length) + 1
        fullPath = decodeURIComponent fullPath

        unless hosted[fullPath]
          hosted[fullPath] = []
          pkg.repoFiles.push fullPath unless fullPath == @packageFile

        hosted[fullPath].push fileNode
      else
        file = new File null, pkg
        file.setSource ExternalSource
        @setInstallFileData file, fileNode
        pkg.files.push file

    # it's a metapackage if the package file not installed at all
    pkg.files[0].install = !!hosted[@packageFile]

    promises = for fullPath, fileNodes of hosted
      @loadHostedFile pkg, fullPath, fileNodes
    Promise.all promises

  loadHostedFile: (pkg, fullPath, fileNodes) ->
    promises = []

    # start by creating the shared uploaded file...
    source = if fullPath == @packageFile
      pkg.files[0]
    else
      source = new File null, pkg
      pkg.files.push source

      promises.push do (source) =>
        {header, content} = await @fetchFile fullPath
        source.content = content

      source

    source.storageName = relative source.storageDirectory(), fullPath

    if fileNodes.length == 1
      # the hosted file is installed once
      @setInstallFileData source, fileNodes[0]
      return
    else if fileNodes.filter((n) => !n.hasAttribute('file')).length == 1
      # the hosted file is installed once under its original storage file name
      # but is also installed under different filenames
      @setInstallFileData source, fileNodes.shift()
    else
      source.install = false

    # ...then create all virtual files sourcing it
    for fileNode in fileNodes
      file = new File null, pkg
      file.setSource source.toSource()
      @setInstallFileData file, fileNode
      pkg.files.push file

    Promise.all promises

  setInstallFileData: (file, node) ->
    file.originName = @index.repo
    file.type = resolveType node.getAttribute('type')
    file.sections = @parseMain(node.getAttribute('main') || '')
    file.platform = @parsePlatform(node.getAttribute('platform') || '')
    file.url = node.textContent || ''
    file.installName = node.getAttribute('file') || @fileName

    unless file.source == ExternalSource
      sourceFile = file.source.file ? file
      storageDir = sourceFile.storageDirectory false
      file.installName = relative storageDir, file.installName
      file.installName = null if file.installName == file.storageName

  fetchFile: (file) ->
    try
      response = await @index.fetchFile file
      content = await response.clone().text()
      header = null
    catch error
      throw new Error "Could not fetch #{file}. #{error.message}"

    if detectBinary content
      content = await response.arrayBuffer()
    else if isIndexable extname(file)
      try
        apiResponse = await @index.fetchAPI 'parse-header',
          method: 'post'
          headers: { 'Content-Type': 'text/plain' }
          body: content

        offset = apiResponse.headers.get 'X-End-Of-Header'
        content = content.substring offset

        header = await apiResponse.json()
      catch error
        throw new Error "Could not parse header of #{file}. #{error.message}"

    {header, content}

export default class Index
  constructor: ->
    @reset()

  reset: ->
    @categories = []
    @packages = []
    @error = null

  load: (@repo) ->
    @reset()

    try
      response = await @fetchFile 'index.xml'
      text = await response.text()
      @loadFromText text
    catch error
      @error = error.message

  loadFromText: (text) ->
    parser = new DOMParser()
    doc = parser.parseFromString text, 'text/xml'

    if doc.documentElement.getElementsByTagName('parsererror').length
      @error = 'Failed to parse the index.'
    else
      @loadDocument doc

  loadDocument: (doc) ->
    @categories = for catNode in doc.getElementsByTagName 'category'
      catNode.getAttribute 'name'

    @packages = for pkgNode in doc.getElementsByTagName 'reapack'
      reapack = new IndexPackage pkgNode, @
      continue unless reapack.isValid()
      reapack

  similarPackages: (userInput) ->
    matches = fuzzysort.go userInput, @packages,
      key: 'name'
      limit: 50
      threshold: -500

    match.obj for match in matches

  fetchFile: (path) ->
    checkedFetch "https://raw.githubusercontent.com/#{@repo}/master/#{path}"

  fetchAPI: (endpoint, options) ->
    url = if process.env.NODE_ENV == 'production'
      "/api/#{endpoint}"
    else
      "http://localhost:8888/#{endpoint}"

    checkedFetch url, options
