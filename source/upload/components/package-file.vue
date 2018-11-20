<template lang="slim">
div
  p
    field-label Resource type
    input-dropdown :value=="{ icon: 'fa-file-text', name: 'ReaScript (same as package type)' }" :choices="availableTypes"

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
    field-label target="sections" optional=true Action List
    input-dropdown#sections value="Main section" v-model="sections" multiple=true :choices="allSections"

  p
    field-label target="platforms" Platform matrix
    input-dropdown#platforms value="All platforms"
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

ScriptSections = [
    id: 'main'
    name: 'Main'
  ,
    id: 'midi_editor'
    name: 'MIDI Editor'
  ,
    id: 'midi_inlineeditor'
    name: 'MIDI Inline Editor'
  ,
    id: 'midi_eventlisteditor'
    name: 'MIDI Event List Editor'
  ,
    id: 'mediaexplorer'
    name: 'Media Explorer'
]

module.exports =
  components: { FieldLabel, InputDropdown, PlatformMatrix }
  data: ->
    sections: []

  computed:
    availableTypes: -> TypeOverrides
    allSections: -> ScriptSections
</script>

<style lang="sass">
</style>
