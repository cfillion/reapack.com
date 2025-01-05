<template lang="slim">
.file-list
  .header: slot
  ul
    li.empty v-if="files.length < 1" The list is empty.
    li (
      v-for="file in files" :class="{ active: current == file }"
      @click=="$emit('select', file)"
    )
      input> (
        type="checkbox" title="Include in the package" @click.stop
        v-if="isUpload(file) && file.canInstall()" v-model="file.install"
      )
      .name
        .label() {{ file.displayName() }}
        .install v-if="showInstallName(file)"
          i.fa.fa-fw.fa-download
          | {{ file.effectiveInstallName() }}
      .btns
        i.fa.fa-copy title="Duplicate file" @click.stop=="$emit('copy', file)"
        i.fa.fa-trash (
          v-if="!file.isPackage" title="Remove file"
          @click.stop=="$emit('remove', file)"
        )
</template>

<script lang="coffee">
import File, { UploadSource, ExternalSource } from '../file'
import PackageFile from './package-file.vue'

export default
  components: { PackageFile }
  props:
    files:
      type: Array
      required: true
    current: Object
  methods:
    isUpload: (file) ->
      file.source == UploadSource
    showInstallName: (file) ->
      @isUpload(file) && file.install &&
        file.effectiveInstallName() != file.effectiveStorageName()
</script>

<style lang="sass" scoped>
@use 'config'
@use 'sass:color'
@use 'upload-mixins'

.file-list
  font-size: 0.8em
  margin-bottom: config.$padding

ul
  margin-left: 0
  list-style-type: none

li, .header
  padding: 4px 8px 4px 8px

.header
  font-family: config.$font-serif

li:not(.empty)
  background-color: config.$table-row-odd
  cursor: pointer
  list-style-type: none
  display: flex
  align-items: center

  &:nth-child(2n)
    background-color: config.$table-row-even

  &:hover
    background-color: config.$background

    .btns
      visibility: visible

  &.active
    background: color.adjust(config.$background, $lightness: -2%)

    .label
      font-weight: bold

input, .btns
  flex-shrink: 0

.btns
  font-size: 1rem
  color: upload-mixins.$input-placeholder
  visibility: hidden

  i
    margin-left: 4px

  i:hover
    color: white

.name
  flex: 1 1 auto
  overflow: hidden
  overflow-wrap: break-word
</style>
