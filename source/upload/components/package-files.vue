<template lang="slim">
.file-editor.group
  .drag-overlay.page-overlay v-if="drag"
  .left-pane
    .lists
      package-file-list (
        v-for="list in lists" :key="list.heading" :files="list.files"
        :current="currentFile" @select="currentFile = $event"
        @copy="copyFile" @remove="removeFile"
      ) {{ list.heading }}
    button type="button" @click="addFile"
      i.fa.fa-plus>
      | Add file
  .file: package-file :file="currentFile"
</template>

<script lang="coffee">
import File, { UploadSource, ExternalSource } from '../file'

import PackageFile from './package-file.vue'
import PackageFileList from './package-filelist.vue'

export default
  components: { PackageFile, PackageFileList }
  props:
    package:
      type: Object
      required: true
  data: ->
    currentFile: null
    newFileCounter: 0
    drag: false
  computed:
    packageFiles: ->
      @package.files.filter (f) -> f.isPackage
    hostedFiles: ->
      @package.files.filter (f) -> !f.isPackage && f.source == UploadSource
    virtualFiles: ->
      @package.files.filter (f) -> f.source != UploadSource
    lists: -> [
        heading: 'Package file'
        files: @packageFiles
      ,
        heading: 'Hosted files'
        files: @hostedFiles
      ,
        heading: 'Additional files'
        files: @virtualFiles
    ]
  watch:
    package:
      immediate: true
      handler: -> @currentFile = @package.files[0]
  mounted: ->
    document.addEventListener 'dragover', @onDragOver
    document.addEventListener 'dragleave', @onDragLeave
    document.addEventListener 'drop', @onDrop
  beforeDestroy: ->
    document.removeEventListener 'dragover', @onDragOver
    document.removeEventListener 'dragleave', @onDragLeave
    document.removeEventListener 'drop', @onDrop
  methods:
    newFileName: (ext) ->
      ext ?= @package.type.defaultExtension || @package.type.extensions[0]
      "New file #{++@newFileCounter}#{ext}"
    addFile: ->
      file = new File @newFileName(), @package
      file.setSource ExternalSource if @package.type.defaultExternal
      @package.files.push @currentFile = file
    copyFile: (file) ->
      copy = Object.assign Object.create(Object.getPrototypeOf(file)), file
      copy.isPackage = false
      copy.setSource file.toSource() if copy.source == UploadSource
      copy.installName = @newFileName file.effectiveExtname()
      @package.files.push @currentFile = copy
    removeFile: (file) ->
      if file.source == UploadSource
        users = @package.findFilesSourcing file

        if users.length > 0
          return unless confirm "Delete '#{file.effectiveStorageName()}'
            and #{users.length} files sourcing it?"

        @doRemoveFile user for user in users

      @doRemoveFile file
    doRemoveFile: (file) ->
      index = @package.files.indexOf file
      @package.files.splice index, 1 if index > -1

      if file == @currentFile
        @currentFile = @package.files[index] || @package.files[index - 1]
    onDragOver: (e) ->
      e.preventDefault()
      e.stopPropagation()
      @drag = true
    onDragLeave: ->
      @drag = false
    onDrop: (e) ->
      e.preventDefault()
      e.stopPropagation()
      @drag = false

      for localFile in e.dataTransfer.files
        file = new File localFile.name, @package

        do (file) =>
          file.setContentFromLocalFile localFile, (err) =>
            file.setSource ExternalSource if err
            @package.files.push @currentFile = file
</script>

<style lang="sass">
@import 'config'

.file-editor
  display: flex
  height: 650px
  padding: 0

.left-pane
  $width: 250px
  border-right: 1px solid $foreground
  padding-top: 4px
  display: flex
  flex-direction: column
  justify-content: space-between
  flex: 0 0 $width
  max-width: $width // prevent text overflows

  button
    margin: $padding
    flex: 0 0 auto

.lists
  overflow-x: auto

.file
  overflow: auto
  overflow-wrap: break-word
  flex: 1 1 auto

  &> div
    padding: $padding

.page-overlay
  position: fixed
</style>
