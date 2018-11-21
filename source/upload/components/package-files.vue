<template lang="slim">
.file-editor.group
  .left-pane
    .lists
      package-file-list :files="[packageFile]" :current="currentFile" @select="currentFile = $event" Package file
      package-file-list :files="hostedFiles" :current="currentFile" @select="currentFile = $event" Hosted files
      package-file-list :files="virtualFiles" :current="currentFile" Additional files
    button @click="addFile"
      i.fa.fa-plus>
      | Add file
  package-file.file :file="currentFile"
</template>

<script lang="coffee">
File = require '../file.coffee'

PackageFile = require './package-file.vue'
PackageFileList = require './package-filelist.vue'

module.exports =
  components: { PackageFile, PackageFileList }
  data: ->
    currentFile: {},
    packageFile: new File('cfillion_Song switcher.lua')
    hostedFiles: [
      new File('cfillion_Song switcher (next).lua')
      new File('cfillion_Song switcher (previous).lua')
      new File('cfillion_Song switcher (reset).lua')
      new File('song_switcher.html')
    ]
    virtualFiles: [
      # {name: 'cfillion_Song switcher.lua'}
      # {name: 'cfillion_Song switcher.lua'}
    ]
    newFileCounter: 0
  mounted: ->
    @currentFile = @packageFile
  methods:
    addFile: ->
      @virtualFiles.push new File("New file #{++@newFileCounter}")
</script>

<style lang="sass">
@import 'config'

.file-editor
  display: flex
  height: 550px
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
</style>
