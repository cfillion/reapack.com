<template lang="slim">
.file-editor.group
  .left-pane
    .file-list
      .header Package file
      ul
        li cfillion_Hello World.lua

      .header Additional files
      ul
        li cfillion_Hello World (background).lua
        li mpl_Float instrument relevant to MIDI editor.lua
    button
      i.fa.fa-plus>
      | Add files
  package-file.file
</template>

<script lang="coffee">
PackageFile = require './package-file.vue'

module.exports =
  components: { PackageFile }
</script>

<style lang="sass">
@import 'config'

.file-editor
  display: flex
  min-height: 400px
  padding: 0

.left-pane
  border-right: 1px solid $foreground
  font-size: 0.8em
  padding-top: 4px
  display: flex
  flex-direction: column
  justify-content: space-between
  flex: 0 0 250px

  button
    margin: 8px
    font-size: 1rem

.file-list
  ul
    margin-left: 0
    list-style-type: none

  li, .header
    padding: 4px 8px 4px 8px

  .header
    font-family: $font-serif

  li
    background-color: $table-row-odd
    cursor: pointer
    list-style-type: none

    &:nth-child(2n)
      background-color: $table-row-even

    &:hover
      background-color: $background

.file
  padding: $padding
  overflow: auto
</style>
