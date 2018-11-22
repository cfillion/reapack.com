<template lang="slim">
.file-editor.group
  .left-pane
    .lists
      package-file-list :files="packageFiles" :current="currentFile" @select="currentFile = $event" Package file
      package-file-list :files="hostedFiles" :current="currentFile" @select="currentFile = $event" Hosted files
      package-file-list :files="virtualFiles" :current="currentFile" Additional files
    button @click="addFile"
      i.fa.fa-plus>
      | Add file
  package-file.file :file="currentFile"
</template>

<script lang="coffee">
import File from '../file'

import PackageFile from './package-file.vue'
import PackageFileList from './package-filelist.vue'

export default
  components: { PackageFile, PackageFileList }
  data: ->
    currentFile: {},
    files: []
    newFileCounter: 0
  computed:
    packageFiles: ->
      @files.filter (f) -> f.isPackage
    hostedFiles: ->
      @files.filter (f) -> !f.isPackage && f.source == File.UPLOAD
    virtualFiles: ->
      @files.filter (f) -> f.source != File.UPLOAD
  created: ->
    @files.push new File('cfillion_Song switcher.lua', true)
    @files.push new File('cfillion_Song switcher (next).lua')
    @files.push new File('cfillion_Song switcher (previous).lua')
    @files.push new File('cfillion_Song switcher (reset).lua')
    @files.push new File('song_switcher.html')
  mounted: ->
    @currentFile = @files[0]
  methods:
    addFile: ->
      @virtualFiles.push new File("New file #{++@newFileCounter}")
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
