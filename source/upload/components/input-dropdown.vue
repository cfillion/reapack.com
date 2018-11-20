<template lang="slim">
div
  button.dropdown(:id="id" type='button' :class="{ active: showMenu }"
      @click="showMenu = !showMenu" ref="button")
    .placeholder v-if="!displayValue" Select a value…
    .value v-if="value"
      i.icon.fa.fa-fw> v-if="value.icon" :class="value.icon"
      | {{ displayValue }}
    i.caret.fa.fa-caret-down
  dropdown-menu(:items="choices" :show="showMenu" :multiple="multiple"
    :checked=="multiple ? value : []" @input="setValue" @change="showMenu = false")
    slot
</template>

<script lang="coffee">
DropdownMenu = require './dropdown-menu.vue'

module.exports =
  components: { DropdownMenu }
  props:
    choices: Array
    id: String
    multiple: Boolean
    value: ''
  data: ->
    showMenu: false
  computed:
    displayValue: ->
      if Array.isArray @value
        @value.map((v) => @formatValue(v)).join ', ' if @value.length > 0
      else
        @value.name || @value
  methods:
    setValue: (val) ->
      if @multiple
        index = @value.indexOf val
        if index > -1
          @value.splice index, 1
        else
          @value.push val
          @value.sort (a, b) => @choices.indexOf(a) - @choices.indexOf(b)
      else
        @$emit 'input', val
    onDocumentClick: (e) ->
      if @showMenu && !@$refs.button.contains(e.target)
        @showMenu = false
        e.preventDefault()
    formatValue: (val) -> val.name || val
  created: ->
    document.addEventListener 'click', @onDocumentClick
  destroyed: ->
    document.removeEventListener 'click', @onDocumentClick
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
