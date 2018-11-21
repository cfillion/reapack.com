<template lang="slim">
.file-list v-if="files.length > 0"
  .header: slot
  ul
    li v-for="(file, i) in files" :class="{ active: current == file }" @click=="$emit('select', file)"
      .btns
        i.fa.fa-copy> title="Duplicate file" @click.stop=="$emit('copy', i)"
        i.fa.fa-trash(v-if="!file.package" title="Remove file"
          @click.stop=="$emit('remove', i)")
      .name
        input>(type="checkbox" title="Include in the package"
          v-model="file.install" @click.stop)
        | {{ file.name }}
</template>

<script lang="coffee">
PackageFile = require './package-file.vue'
PackageFileList = require './package-filelist.vue'

module.exports =
  components: { PackageFile, PackageFileList }
  props:
    files:
      type: Array
      required: true
    current: Object
</script>

<style lang="sass" scoped>
@import 'upload-mixins'

.file-list
  font-size: 0.8em
  margin-bottom: $padding

ul
  margin-left: 0
  list-style-type: none

li, .header
  padding: 4px 8px 4px 8px

.header
  font-family: $font-serif

li
  background-color: $table-row-odd
  cursor: pointer
  list-style-type: none
  overflow-wrap: break-word

  &:nth-child(2n)
    background-color: $table-row-even

  &:hover
    background-color: $background

    .btns
      visibility: visible

  &.active
    background: darken($background, 2%)
    font-weight: bold

.btns
  float: right
  font-size: 1rem
  color: $input-placeholder
  visibility: hidden

  i:hover
    color: white
</style>
