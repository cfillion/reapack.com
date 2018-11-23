<template lang="slim">
div
  p
    field-label target="source" File source
    input-dropdown#source(v-model="file.source" :choices="availableSources"
      :disabled="file.isPackage")

  template v-if="file.source == $options.uploadSource"
    p
      field-label Storage directory
      | /{{ category || 'Category' }}/

    p v-if="file.source == $options.uploadSource"
      field-label target="storage-name" Storage file name
      input#storage-name type="text" v-model="file.name"

  p v-else-if="file.source == $options.externalSource"
    field-label target="download-url" Download URL
    input#download-url type="url" v-model="file.url"

  p
    field-label target="file-type" Resource type
    input-dropdown#file-type v-model="type" :choices="availableTypes"

  template v-if="file.install"
    p
      field-label target="target-name" optional=true Install location
      input#target-name type="text" :placeholder="file.name"
      | &lt;resource path&gt;/Scripts/ReaTeam Scripts/Development/cfillion_Interactive ReaScript.lua

    p v-if="type.actionList"
      field-label target="sections" optional=true Action List
      input-dropdown#sections v-model="file.sections" multiple=true :choices="allSections"

    p
      field-label target="platforms" Target platform
      input-dropdown#platforms :value="platformName"
        platform-matrix v-model="file.platform" @display="platformName = $event"

  p v-if="file.source == $options.uploadSource"
    field-label target="contents" Contents
    textarea#contents rows="20"
</template>

<script lang="coffee">
import File from '../file'
import * as Types from '../types'

import FieldLabel from './field-label.vue'
import InputDropdown from './input-dropdown.vue'
import PlatformMatrix from './platform-matrix.vue'

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

DisabledType = { icon: 'fa-ban', name: "Don't install" }

export default
  uploadSource: File.UPLOAD
  externalSource: File.EXTERNAL
  components: { FieldLabel, InputDropdown, PlatformMatrix }
  props:
    file:
      type: Object
      required: true
  data: ->
    platformName: ''
  computed:
    sameAsPackageType: ->
      { value: '', icon: 'fa-file-code-o', name: 'ReaScript (same as package)' }
    availableSources: ->
      sources = [
        File.UPLOAD,
        File.EXTERNAL,
      ]
      sources
    type:
      get: ->
        if @file.install
          Types[@file.type] || @sameAsPackageType
        else
          DisabledType
      set: (type) ->
        if type == DisabledType
          @file.install = false
        else
          @file.type = type.value
          @file.install = true
    availableTypes: ->
      types = []
      types.push @sameAsPackageType
      types.push DisabledType
      return types if @file.isPackage

      types.push { separator: true }
      for key in Object.keys(Types).sort()
        types.push { value: key, Types[key]...}
      types

    allSections: -> ScriptSections
</script>

<style lang="sass">
</style>
