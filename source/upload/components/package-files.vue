<template lang="slim">
.file-editor.group :class="{ fullscreen }"
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
  i.fa.fa-arrows-alt.toggle-fullscreen (
    title="Toggle fullscreen" @click=="$emit('fullscreen', !fullscreen)"
  )
</template>

<script lang="coffee">
import File, { UploadSource, ExternalSource } from '../file'

import DragDropMixin from '../mixins/drag-drop.coffee'

import PackageFile from './package-file.vue'
import PackageFileList from './package-filelist.vue'

export default
  mixins: [ DragDropMixin ]
  components: { PackageFile, PackageFileList }
  props:
    package:
      type: Object
      required: true
    fullscreen: Boolean
  data: ->
    currentFile: null
    newFileCounter: 0
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
      copy.sections = file.sections.slice()
      copy.setSource file.toSource() if copy.source == UploadSource
      copy.installName = @newFileName file.effectiveInstallExtname()
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
    loadLocalFile: (localFile) ->
      file = new File localFile.name, @package

      file.setContentFromLocalFile localFile, (err) =>
        file.setSource ExternalSource if err
        @package.files.push @currentFile = file
</script>

<style lang="sass">
@use 'config'

.file-editor
  box-sizing: border-box
  display: flex
  height: 650px
  padding: 0
  position: relative

  &:hover .toggle-fullscreen
    display: block

@mixin left-pane-width($width)
  flex: 0 0 $width
  max-width: $width // prevent text overflows

.left-pane
  $width: 250px
  border-right: 1px solid config.$foreground
  padding-top: 4px
  display: flex
  flex-direction: column
  justify-content: space-between
  +left-pane-width(250px)

  button
    margin: config.$padding
    flex: 0 0 auto

.lists
  overflow-x: auto

.file
  flex: 1 1 auto
  overflow-wrap: break-word
  overflow: auto
  scrollbar-width: thin

  &> div
    padding: config.$padding

.page-overlay
  position: fixed

.toggle-fullscreen
  position: absolute
  top: 0
  right: 0
  margin: 10px
  text-shadow: none
  cursor: pointer
  display: none
  opacity: 0.2

  &:hover
    opacity: 0.5

.fullscreen
  position: fixed
  top: 0
  left: 0
  width: 100vw
  height: 100vh
  border-style: none
  border-radius: unset

  .left-pane
    +left-pane-width(300px)

  .CodeMirror
    height: 90vh
</style>
