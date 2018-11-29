import fuzzysort from 'fuzzysort'
import { relative, extname } from 'path'

import * as Types from './types'
import Package, { LinkTypes } from './package'
import File, { ExternalSource, ScriptSections, isIndexable } from './file'

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

checkedFetch = (url, options = {}) -> new Promise (resolve, reject) =>
  fetch url, options
  .then (response) =>
    if response.ok
      resolve response
    else
      reject new Error "Server replied with
        #{response.status} #{response.statusText}."

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
        fileNodes: verNode.getElementsByTagName 'source'

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

  load: -> new Promise (resolve, reject) =>
    pkg = new Package @type
    pkg.name = @name
    pkg.category = @category

    for linkNode in @linkNodes
      type = resolveLinkType(linkNode.getAttribute('rel') || 'website')
      name = linkNode.textContent
      url = linkNode.getAttribute 'href'
      [name, url] = [url, name] unless url
      pkg.links.push { type, name, url } if type && url

    @fetchFile @packageFile
    .then ({header, content}) =>
      pkg.version = header.version || ''
      pkg.author = header.author || ''
      pkg.about = header.about || ''
      pkg.changelog = header.changelog || ''
      pkg.files[0].content = content

      current = @findVersion header.version

      unless current
        return reject "Cannot find version '#{header.version}' in the index."

      fileNodes = current.getElementsByTagName 'source'
      filePromises = @loadFiles fileNodes, pkg

      Promise.all(filePromises)
      .then => resolve pkg
    .catch (error) => reject error

  loadFiles: (fileNodes, pkg) ->
    hosted = {}
    hostedPrefix = "https://github.com/#{@index.repo}/raw/"
    promises = []

    for fileNode in fileNodes
      if fileNode.textContent.startsWith hostedPrefix
        fullPath = fileNode.textContent.substring \
          fileNode.textContent.indexOf('/', hostedPrefix.length) + 1
        fullPath = decodeURIComponent fullPath

        hosted[fullPath] ||= []
        hosted[fullPath].push fileNode
      else
        file = new File null, pkg
        file.setSource ExternalSource
        @setInstallFileData file, fileNode
        pkg.files.push file

    for fullPath, fileNodes of hosted
      # start by creating the shared uploaded file
      source = if fullPath == @packageFile#fileNodes[0].hasAttribute 'file'
        pkg.files[0]
      else
        source = new File null, pkg
        pkg.files.push source

        do (source) =>
          promise = @fetchFile fullPath
          promise.then ({header, content}) => source.content = content
          promises.push promise

        source

      source.storageName = relative source.storageDirectory(), fullPath

      if source.isPackage && source.storageName == source.defaultName()
        source.storageName = null

      if fileNodes.length == 1
        @setInstallFileData source, fileNodes[0]
        continue

      source.install = false

      # then create all virtual files sourcing it
      for fileNode in fileNodes
        file = new File null, pkg
        file.setSource source.toSource()
        @setInstallFileData file, fileNode
        pkg.files.push file

    promises

  setInstallFileData: (file, node) ->
    file.type = resolveType node.getAttribute('type')
    file.sections = @parseMain(node.getAttribute('main') || '')
    file.platform = @parsePlatform(node.getAttribute('platform') || '')
    file.url = node.textContent || ''
    file.installName = node.getAttribute('file') || ''

    unless file.source == ExternalSource
      sourceFile = file.source.file ? file
      storageDir = sourceFile.storageDirectory false
      file.installName = relative storageDir, file.installName
      file.installName = null if file.installName == file.storageName

  fetchFile: (file) -> new Promise (resolve, reject) =>
    content = ''
    parseHeader = isIndexable extname(file)

    promise = @index.fetchFile file
    .then (response) => response.text()
    .then (text) =>
      content = text

      if parseHeader
        @index.fetchAPI 'parse-header',
          method: 'post'
          headers: { 'Content-Type': 'text/plain' }
          body: text
        .catch (error) =>
          reject new Error "Could not parse header of #{file}. #{error.message}"
      else
        resolve header: null, content: text
    .catch (error) => reject new Error "Could not fetch #{file}. #{error.message}"

    if parseHeader
      promise.then (response) =>
        return unless response
        offset = response.headers.get 'X-End-Of-Header'
        content = content.substring offset
        response.json()
      .then (header) => resolve {header, content}

export default class Index
  constructor: ->
    @categories = []
    @packages = []
    @error = null

  load: (@repo) ->
    @constructor()

    @fetchFile 'index.xml'
    .then (response) => response.text()
    .then (text) => @loadFromText text
    .catch (error) => @error = error.message

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
    checkedFetch "http://localhost:8080/#{endpoint}", options
