<template lang="slim">
.file-editor.group
  .left-pane
    .lists
      package-file-list (
        v-for="list in lists" :key="list.heading" :files="list.files"
        :current="currentFile" @select="currentFile = $event"
      ) {{ list.heading }}
    button @click="addFile"
      i.fa.fa-plus>
      | Add file
  package-file.file :file="currentFile"
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
    currentFile: null,
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
  created: ->
    @currentFile = @package.files[0]
  methods:
    addFile: ->
      defext = @package.type.defaultExtension || @package.type.extensions[0]

      file = new File "New file #{++@newFileCounter}#{defext}", @package
      file.setSource ExternalSource if @package.type.defaultExternal

      @package.files.push @currentFile = file
  watch:
    package: ->
      @currentFile = @package.files[0]
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
    margin: 8px
    flex: 0 0 auto

.lists
  overflow-x: auto

.file
  padding: $padding
  overflow: auto
  overflow-wrap: break-word
  flex: 1 1 auto
</style>
