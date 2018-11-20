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
  .file-2
    p
      field-label Resource type
      input-dropdown :value=="{ icon: 'fa-file-text', name: 'ReaScript (same as package type)' }" :choices="types"

    p
      field-label Storage directory
      | /Development

    p
      field-label target="storage-name" Storage file name
      input#storage-name type="text"

    p
      field-label target="target-name" optional=true Install location
      input#target-name type="text"
      | &lt;resource path&gt;/Scripts/ReaTeam Scripts/Development/cfillion_Interactive ReaScript.lua

    p
      field-label Action List
      input-dropdown value="Main section"

    p
      field-label Platform matrix
      input-dropdown value="All platforms"
        platform-matrix

    p
      field-label target="contents" Contents
      textarea#contents
</template>

<script lang="coffee">
Types = require '../types.coffee'

FieldLabel = require './field-label.vue'
InputDropdown = require './input-dropdown.vue'
PlatformMatrix = require './platform-matrix.vue'

TypeOverrides = [
  '(Same as package type)'
  Types.reascript
  Types.jsfx
  Types.theme
  Types.langpack
  Types.extension
]

module.exports =
  components: { FieldLabel, InputDropdown, PlatformMatrix }
  computed:
    types: -> TypeOverrides
</script>

<style lang="sass">
@import 'config'

.file-editor
  display: flex
  min-height: 400px
  padding: 0

.file-2
  padding: $padding
  overflow-y: auto
  flex: 1 1 auto

.left-pane
  width: 250px
  border-right: 1px solid $foreground
  font-size: 0.8em
  padding-top: 4px
  display: flex
  flex-direction: column
  justify-content: space-between

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
</style>
