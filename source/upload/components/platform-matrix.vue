<template lang="slim">
table
  thead
    tr
      th
      th v-for="platform in cols" @click="toggleCol(platform)" {{ platform.name }}
  tbody
    tr v-for="arch in rows"
      th @click="toggleRow(arch)" {{ arch.name }}
      td v-for="platform in cols"
        input(type="checkbox" v-if="arch.platforms[platform.id]"
          :checked="isChecked(platform, arch)" @input=="toggle(platform, arch)")
</template>

<script lang="coffee">
Platforms = [
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
    name: '32-bit'
    platforms:
      linux: 'linux32'
      darwin: 'darwin32'
      windows: 'win32'
  ,
    name: '64-bit'
    platforms:
      linux: 'linux64'
      darwin: 'darwin64'
      windows: 'win64'
]

module.exports =
  props:
    platforms: Array
  computed:
    rows: -> Architectures
    cols: -> Platforms
    isAny: -> @platforms.length == 0
  methods:
    has: (key) -> @isAny || @platforms.indexOf(key) > -1
    isChecked: (platform, arch) ->
      @has(platform.id) || @has(arch.platforms[platform.id])
    toggle: (platform, arch) ->
    formatValue: ->
      return 'All platforms' if @isAny

      formats = []

      for platform in Platforms
        if @has platform.id
          formats.push "#{platform.name} (all)"
          continue

        archs = []
        for arch in Architectures
          archs.push arch.name if @has arch.platforms[platform.id]
        formats.push "#{platform.name} (#{archs.join ','})" if archs

      formats

  mounted: ->
    @$emit 'display', @formatValue()
</script>

<style lang="sass" scoped>
th:not(:empty)
  cursor: pointer

td
  text-align: center

tbody tr:last-child
  border-bottom: none
</style>
