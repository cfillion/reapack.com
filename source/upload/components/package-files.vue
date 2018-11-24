<template lang="slim">
.file-editor.group
  .left-pane
    .lists
      package-file-list :files="packageFiles" :current="currentFile" @select="currentFile = $event" Package file
      package-file-list :files="hostedFiles" :current="currentFile" @select="currentFile = $event" Hosted files
      package-file-list :files="virtualFiles" :current="currentFile" @select="currentFile = $event" Additional files
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
  created: ->
    @currentFile = @package.files[0]
  methods:
    addFile: ->
      file = new File "New file #{++@newFileCounter}", @package
      @package.files.push file
      @currentFile = file
  watch:
    package: ->
      @currentFile = @package.files[0]
</script>

<style lang="sass">
@import 'config'

.file-editor
  display: flex
  height: 600px
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

.lists
  overflow-x: auto

.file
  padding: $padding
  overflow: auto
  flex: 1 1 auto
</style>
