<template lang="slim">
div
  button :id="id" type='button' @click="showMenu = !showMenu" @blur="showMenu = false"
    .placeholder v-if="!value" Select a value...
    .value v-if="value" {{ value }}
    i.fa.fa-caret-down
  dropdown-menu v-if="showMenu" :items="choices" @select="setValue"
</template>

<script lang="coffee">
DropdownMenu = require './dropdown-menu.vue'

module.exports =
  components: { DropdownMenu }
  props:
    id: String
    choices: Array
  data: ->
    showMenu: false
    value: ''
  methods:
    setValue: (val) ->
      @value = val
      @showMenu = false
      @emit 'input', val
</script>

<style lang="sass" scoped>
@import 'config'

button
  align-items: baseline
  display: flex
  justify-content: space-between
  overflow: hidden
  text-align: left
  white-space: nowrap

.value, .placeholder
  overflow: hidden
  text-overflow: ellipsis

i
  padding-left: 10px
  padding-right: 5px
</style>
