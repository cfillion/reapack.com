<template lang="slim">
ul
  li v-for="item in items" @click=="$emit('select', item)" {{ item }}
</template>

<script lang="coffee">
module.exports =
  props:
    items: Array
</script>

<style lang="sass" scoped>
@import 'config'

$radius: 4px

ul
  position: absolute
  min-width: 200px
  border-radius: $radius
  margin-left: 0
  // todo: reuse box-shadow  and border from upload.sass
  box-shadow: 0 0 2px black
  border: 1px solid $foreground
  max-height: 100px
  overflow: hidden auto
  margin-top: -1px

li
  background-color: $table-row-odd
  list-style-type: none
  padding: 8px 4px 4px 8px
  cursor: pointer
  font-size: 0.9em

  &:first-child
    border-top-left-radius: $radius
    border-top-right-radius: $radius

  &:nth-child(2n)
    background-color: $table-row-even

  &:last-child
    border-bottom-left-radius: $radius
    border-bottom-right-radius: $radius

  &:hover
    background-color: $background
</style>
