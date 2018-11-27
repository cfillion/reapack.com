<template lang="slim">
.drop-target (
  @dragover="onDragOver($event)" @dragleave="drag = false"
  @drop="handleDrop($event)"
)
  .drag-overlay v-if="drag"

  p
    field-label target="source" File source
    input-dropdown#source (
      :value="file.source" @input="setSource"
      :choices="availableSources" :disabled="file.isPackage"
    )

  template v-if="file.source == $options.UploadSource"
    p
      field-label Storage directory
      | /{{ file.storageDirectory() }}/

    p v-if="file.source == $options.UploadSource"
      field-label target="storage-name" Storage file name
      input#storage-name (
        type="text" v-model.trim="file.storageName" :pattern="storageNamePattern"
        :placeholder="file.effectiveStorageName()"
      )

  p v-else-if="file.source == $options.ExternalSource"
    field-label target="download-url" Download URL
    input#download-url type="url" required=true v-model.trim="file.url"
    | Available variables:
      <code title="The path of the file relative to the repository">$path</code>,
      <code title="The hash of the commit being indexed or &quot;master&quot; if unavailable">$commit</code>,
      <code title="The version of the package being indexed">$version</code> and
      <code title="The package being indexed (path relative to the repository)">$package</code>.

  p
    field-label target="file-type" Resource type
    input-dropdown#file-type (
      v-model="type" :choices="availableTypes" :disabled="!file.canInstall()"
    )

  template v-if="file.install"
    p
      field-label (
        target="target-name" :optional="file.source == $options.UploadSource"
      ) Install file name
      input#target-name (
        type="text" v-model.trim="file.installName"
        :placeholder="file.effectiveInstallName()"
      )
      | &lt;resource path&gt;/{{ file.installPath() }}

    p v-if="file.effectiveType().actionList"
      field-label target="sections" optional=true Action List
      input-dropdown#sections(v-model="file.sections" multiple=true
        :choices="$options.ScriptSections")

    p
      field-label target="platforms" Target platform
      input-dropdown#platforms :value="platformName"
        platform-matrix v-model="file.platform" @display="platformName = $event"

  template v-if="file.source == $options.UploadSource"
    p
      field-label Contents
      template v-if="isBinary"
        ' Binary file loaded from {{ file.localName }} ({{ contentSize }}).
        a> href="#" @click.prevent=="file.content = ''" Click here
        | to reset.
      package-file-content (
        v-else="" v-model="file.content"
        :header="header" :filename="file.effectiveInstallName()"
      )

    p.error.binary-header v-if=="isBinary && (file.isPackage || header)"
      | Warning: The metadata header generated for this file type will not be inserted.
      pre v-if="header" {{ header }}

    p
      button> @click=="$refs.fileInput.click()"
        i.fa.fa-folder-open>
        | Open local file
      | ...or drag/drop here
      input type="file" ref="fileInput" @change="fileInputChanged"
</template>

<script lang="coffee">
import File, { UploadSource, ExternalSource, ScriptSections } from '../file'
import * as Types from '../types'

import FieldLabel from './field-label.vue'
import InputDropdown from './input-dropdown.vue'
import PackageFileContent from './package-file-content.vue'
import PlatformMatrix from './platform-matrix.vue'

import filesize from 'filesize'

DisabledType = { icon: 'fa-ban', name: "Don't install" }

export default
  UploadSource: UploadSource, ExternalSource: ExternalSource,
  ScriptSections: ScriptSections,
  components: { FieldLabel, InputDropdown, PackageFileContent, PlatformMatrix }
  props:
    file:
      type: Object
      required: true
  data: ->
    platformName: ''
    drag: false
  computed:
    sameAsPackageType: ->
      name = @file.package.type.name
      name += ' (same as package)' unless @file.isPackage

      sameAsPackage: true
      icon: @file.package.type.icon
      name: name
    availableSources: ->
      sources = [
        UploadSource,
        ExternalSource,
      ]

      otherFiles = (file.toSource() for file in @file.package.files \
        when file != @file && file.source == UploadSource && file.canInstall())

      if otherFiles.length > 0
        sources.push { separator: true }
        sources.push otherFiles...

      sources
    type:
      get: ->
        if @file.install
          @file.type || @sameAsPackageType
        else
          DisabledType
      set: (type) ->
        if type == DisabledType
          @file.install = false
        else
          @file.type = if type.sameAsPackage then null else type
          @file.install = true
    availableTypes: ->
      types = []
      types.push @sameAsPackageType
      types.push DisabledType if @file.source == UploadSource
      return types if @file.isPackage

      types.push { separator: true }
      types.push Types[key] for key in Object.keys(Types).sort() \
        when Types[key] != @file.package.type
      types
    storageNamePattern: ->
      return unless @file.isPackage

      escapedExts = for ext in @file.package.type.extensions
        (for c in ext
          if c == '.'
            '\\.'
          else
            "[#{c.toUpperCase()}#{c.toLowerCase()}]"
        ).join('')

      ".+(#{escapedExts.join '|'})"
    header: -> @file.header()
    isBinary: -> @file.isBinary()
    contentSize: -> filesize @file.content.byteLength
  methods:
    setSource: (source) ->
      if @file.source == UploadSource
        users = @file.package.findFilesSourcing @file

        if users.length > 0
          alert "Cannot change source of '#{@file.effectiveStorageName()}'
          because #{users.length} additional files are sourcing it."
          return

      @file.setSource source
    fileInputChanged: ->
      @loadLocalFile localFile if localFile = @$refs.fileInput.files[0]
      @$refs.fileInput.value = ''
    onDragOver: (e) ->
      return unless @file.source == UploadSource
      e.preventDefault()
      e.stopPropagation()
      @drag = true
    handleDrop: (e) ->
      return unless @drag
      e.preventDefault()
      e.stopPropagation()
      @drag = false
      @loadLocalFile localFile if localFile = e.dataTransfer.files[0]
    loadLocalFile: (localFile) ->
      @file.setContentFromLocalFile localFile, (err) -> alert err if err
</script>

<style lang="sass">
@import 'config'

label
  display: block

code[title]
  cursor: help
  text-decoration: underline dotted

input[type=file]
  opacity: 0
  position: absolute
  top: -100px

.binary-header pre
  font-family: monospace
  font-size: 14px
  margin-top: $padding
</style>
