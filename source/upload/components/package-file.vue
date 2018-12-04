<template lang="slim">
.drop-target @dragover="onDragOver" @dragleave="onDragLeave" @drop="onDrop"
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
      br
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
    ' Available variables:
    template v-for="(variable, index) in $options.urlVariables"
      code.help :title="variable.desc"
        | ${{ variable.name }}
      template v-if="index < $options.urlVariables.length - 1"
        ' ,
    | .

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
        type="text" v-model.trim="file.installName" :pattern="installNamePattern"
        :placeholder="file.effectiveInstallName()"
      )
      | &lt;resource path&gt;/{{ file.fullInstallPath() }}

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
        br
        ' Binary file loaded from {{ file.originName }} ({{ contentSize }}).
        a> href="#" @click.prevent=="file.content = ''" Click here
        | to reset.
      package-file-content (
        v-else="" v-model="file.content"
        :header="header" :filename="file.effectiveInstallName()"
      )

    p.error#binary-header v-if=="isBinary && (file.isPackage || header)"
      | Warning: The metadata header generated for this file type will not be inserted.
      pre v-if="header" {{ header }}

    p
      button#load-file> type="button" @click=="$refs.fileInput.click()"
        i.fa.fa-folder-open>
        | Open local file
      | ...or drag/drop here
      input type="file" ref="fileInput" @change="fileInputChanged"
</template>

<script lang="coffee">
import File, { UploadSource, ExternalSource, ScriptSections } from '../file'
import { PathPattern, makeExtensionPattern } from '../file-utils'
import * as Types from '../types'

import DragDropMixin from '../mixins/drag-drop.coffee'

import FieldLabel from './field-label.vue'
import InputDropdown from './input-dropdown.vue'
import PackageFileContent from './package-file-content.vue'
import PlatformMatrix from './platform-matrix.vue'

import filesize from 'filesize'

DisabledType = { icon: 'fa-ban', name: "Don't install" }

export default
  UploadSource: UploadSource, ExternalSource: ExternalSource,
  ScriptSections: ScriptSections,
  urlVariables: [
      name: 'path'
      desc: 'The path of the file relative to the repository'
    ,
      name: 'commit'
      desc: 'The hash of the commit being indexed or "master" if unavailable'
    ,
      name: 'version'
      desc: 'The version of the package being indexed'
    ,
      name: 'package'
      desc: 'The package being indexed (path relative to the repository)'
  ]
  mixins: [ DragDropMixin ]
  components: { FieldLabel, InputDropdown, PackageFileContent, PlatformMatrix }
  props:
    file:
      type: Object
      required: true
  data: ->
    platformName: ''
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
      extensionPattern = if @file.isPackage
        makeExtensionPattern @file.package.type.extensions
      else
        ''

      PathPattern + extensionPattern
    installNamePattern: -> PathPattern
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
    onDragOver: (event) ->
      if @file.source == UploadSource
        DragDropMixin.methods.onDragOver.call this, event
    loadLocalFile: (localFile) ->
      @file.setContentFromLocalFile localFile, (err) -> alert err if err
</script>

<style lang="sass">
@import 'config'

input[type=file]
  opacity: 0
  position: absolute
  top: -100px

#binary-header > pre
  font-family: monospace
  font-size: 14px
  margin-top: $padding

#load-file
  margin: 0
</style>
