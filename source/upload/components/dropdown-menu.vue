<template lang="slim">
.dropdown-menu(v-show="show" @click.stop)
  slot
    ul
      li.legend v-if="legend" {{ legend }}
      li (
        v-for="item in items" @click=="select(item)"
        :class=="{ separator: item.separator, placeholder: item.disabled,
          item: !item.separator && !item.disabled}"
      )
        template v-if="!item.separator"
          slot name="item" :item="item"
            input type="checkbox" v-if="multiple" :checked=="isChecked(item)"
            i.fa.fa-fw v-if="item.icon" :class="item.icon"
            | {{ item.name || item }}
      li.placeholder v-if="!items || !items.length" This list is empty.
</template>

<script lang="coffee">
export default
  props:
    button: Node
    checked: Array
    items: Array
    multiple: Boolean
    legend: String
    show: Boolean
  methods:
    select: (item) ->
      return if item.separator || item.disabled
      @$emit 'input', item
      @$emit 'leave' unless @multiple
    isChecked: (item) -> @checked?.includes item
    installListener: (add = true) ->
      f = if add then document.addEventListener else document.removeEventListener
      f 'click', @onDocumentClick, true
    onDocumentClick: (event) ->
      if @show && !@button?.contains(event.target) && !@$el.contains(event.target)
        event.preventDefault()
        @$emit 'leave'
  watch:
    show:
      immediate: true
      handler: (show) ->
        @installListener show
        @$el.scrollTop = 0 if @$el
  beforeDestroy: -> @installListener false
</script>

<style lang="sass" scoped>
@import 'upload-mixins'

$radius: 4px

.dropdown-menu
  +input-field
  background-color: $table-row-odd
  border-radius: $radius
  box-sizing: border-box
  margin-top: -5px
  max-height: 400px
  min-width: 200px
  position: absolute
  z-index: 1

  // two value overflow shorthand not supported by Safari
  overflow-x: hidden
  overflow-y: auto

ul
  margin-left: 0

li
  cursor: default
  font-size: 0.9em
  list-style-type: none
  padding: 8px 8px 4px 8px

  .fa
    padding-right: 4px

  &.item
    cursor: pointer
    background-color: $table-row-odd

    &:hover
      background-color: $background

  &.separator
    padding: 0
    border-top: 1px solid $input-placeholder

  &.legend
    font-size: 0.8em
    font-style: italic

  &:first-child
    border-top-left-radius: $radius
    border-top-right-radius: $radius

  &:nth-child(2n)
    background-color: $table-row-even

  &:last-child
    border-bottom-left-radius: $radius
    border-bottom-right-radius: $radius
</style>
