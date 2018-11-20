<template lang="slim">
div
  button.dropdown(:id="id" type='button' :class="{ active: showMenu }"
      @click.stop="showMenu = !showMenu" ref="button")
    .placeholder v-if="!value" Select a value…
    .value v-if="value"
      i.icon.fa.fa-fw> v-if="value.icon" :class="value.icon"
      | {{ value.name || value }}
    i.caret.fa.fa-caret-down
  dropdown-menu :items="choices" :show="showMenu" @select="setValue"
    slot
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
      @$emit 'input', val
    onDocumentClick: (e) ->
      if @showMenu && e.target != @$refs.button
        @showMenu = false
        e.preventDefault()
  created: ->
    document.addEventListener 'click', @onDocumentClick, true
  destroyed: ->
    document.removeEventListener 'click', @onDocumentClick, true
</script>

<style lang="sass" scoped>
@import 'upload-mixins'

button
  align-items: baseline
  display: flex
  justify-content: space-between
  overflow: hidden
  text-align: left
  white-space: nowrap

  &.active
    box-shadow: $input-inset-shadow, input-glow($foreground)

.value, .placeholder
  overflow: hidden
  text-overflow: ellipsis

.caret
  padding-left: 10px
  padding-right: 5px
</style>
