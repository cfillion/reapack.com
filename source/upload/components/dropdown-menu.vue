<template lang="slim">
.dropdown-menu(v-show="show" @click.stop)
  slot
    ul
      li(v-for="item in items" @click=="select(item)"
          :class=="{ separator: item.separator }")
        template v-if="!item.separator"
          input type="checkbox" v-if="multiple" :checked=="isChecked(item)"
          i.fa.fa-fw> v-if="item.icon" :class="item.icon"
          | {{ item.name || item }}
      li.placeholder v-if="!items" This list is empty.
</template>

<script lang="coffee">
export default
  props:
    items: Array
    multiple: Boolean
    checked: Array
    show: Boolean
  methods:
    select: (item) ->
      return if item.separator
      @$emit 'input', item
      @$emit 'change', item unless @multiple
    isChecked: (item) ->
      @checked?.indexOf(item) > -1
</script>

<style lang="sass" scoped>
@import 'upload-mixins'

$radius: 4px

.dropdown-menu
  +input-field
  background-color: $table-row-odd
  border-radius: $radius
  margin-top: -5px
  max-height: 400px
  min-width: 200px
  overflow: hidden auto
  position: absolute
  z-index: 1

ul
  margin-left: 0

li
  background-color: $table-row-odd
  cursor: pointer
  font-size: 0.9em
  list-style-type: none
  padding: 8px 8px 4px 8px

  &.placeholder
    cursor: default

  &.separator
    padding: 0
    border-top: 1px solid $input-placeholder

  &:first-child
    border-top-left-radius: $radius
    border-top-right-radius: $radius

  &:nth-child(2n)
    background-color: $table-row-even

  &:last-child
    border-bottom-left-radius: $radius
    border-bottom-right-radius: $radius

  &:hover:not(.placeholder):not(.separator)
    background-color: $background
</style>
