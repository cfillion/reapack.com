<template lang="slim">
table
  thead
    tr
      td
      th v-for="system in $options.systems" {{ system.name }}
  tbody
    tr v-for="arch in $options.architectures"
      th() {{ arch.name }}
      td v-for="system in $options.systems"
        input(type="radio" v-model="valueProxy"
          v-if="system.id in arch.platforms" :value="arch.platforms[system.id]")
</template>

<script lang="coffee">
OperatingSystems = [
    id: 'all'
    name: 'All'
  ,
    id: 'linux'
    name: 'Linux'
  ,
    id: 'darwin'
    name: 'macOS'
  ,
    id: 'windows'
    name: 'Windows'
]

Architectures = [
    name: 'All'
    platforms:
      all: ''
      linux: 'linux'
      darwin: 'darwin'
      windows: 'windows'
  ,
    name: 'x86 32-bit'
    platforms:
      linux: 'linux32'
      darwin: 'darwin32'
      windows: 'win32'
  ,
    name: 'x86 64-bit'
    platforms:
      linux: 'linux64'
      darwin: 'darwin64'
      windows: 'win64'
  ,
    name: 'ARM 32-bit'
    platforms:
      linux: 'linux-armv7l'
  ,
    name: 'ARM 64-bit'
    platforms:
      linux: 'linux-aarch64'
]

export default
  architectures: Architectures
  systems: OperatingSystems
  props:
    value:
      type: String
      required: true
  computed:
    valueProxy:
      get: -> @value
      set: (val) -> @$emit 'input', val
  methods:
    formatValue: ->
      return "All platforms" unless @value

      for arch in Architectures
        for system, value of arch.platforms
          if value == @value
            return "#{@systemName(system)} (#{arch.name})"

      @value # fallback for unknown platforms
    systemName: (id) ->
      return system.name for system in OperatingSystems when system.id == id
      'Unknown'
  watch:
    value: -> @$emit 'display', @formatValue()
  mounted: -> @$emit 'display', @formatValue()
</script>

<style lang="sass" scoped>
td
  text-align: center

tbody tr:last-child
  border-bottom: none
</style>
