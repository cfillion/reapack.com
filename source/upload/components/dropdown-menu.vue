<template lang="slim">
ul v-if="show"
  li v-for="item in items" @click=="$emit('select', item)"
    i.fa.fa-fw> v-if="item.icon" :class="item.icon"
    | {{ item.name || item }}
  li.placeholder v-if="!items" No choices left.
</template>

<script lang="coffee">
module.exports =
  props:
    items: Array
    show: Boolean
</script>

<style lang="sass" scoped>
@import 'upload-mixins'

$radius: 4px

ul
  +input-field
  border-radius: $radius
  margin-left: 0
  margin-top: -1px
  max-height: 100px
  min-width: 200px
  overflow: hidden auto
  position: absolute

li
  background-color: $table-row-odd
  cursor: pointer
  font-size: 0.9em
  list-style-type: none
  padding: 8px 4px 4px 8px

  &.placeholder
    cursor: default

  &:first-child
    border-top-left-radius: $radius
    border-top-right-radius: $radius

  &:nth-child(2n)
    background-color: $table-row-even

  &:last-child
    border-bottom-left-radius: $radius
    border-bottom-right-radius: $radius

  &:hover:not(.placeholder)
    background-color: $background
</style>
