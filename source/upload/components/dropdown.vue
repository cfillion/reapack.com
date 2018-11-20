<template lang="slim">
div
  button :id="id" type='button' @click="showMenu = !showMenu"
    .placeholder v-if="!value" Select a value…
    .value v-if="value"
      i.icon.fa.fa-fw> v-if="value.icon" :class="value.icon"
      | {{ value.name || value }}
    i.caret.fa.fa-caret-down
  dropdown-menu v-if="showMenu" :items="choices" @select="setValue"
</template>

<script lang="coffee">
DropdownMenu = require './dropdown-menu.vue'

module.exports =
  components: { DropdownMenu }
  props:
    id: String
    choices: Array
    value: ''
  data: ->
    showMenu: false
  methods:
    setValue: (val) ->
      @showMenu = false
      @$emit 'input', val
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

.caret
  padding-left: 10px
  padding-right: 5px
</style>
