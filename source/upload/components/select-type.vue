<template lang="slim" functional>
.select-type
  p Select a primary REAPER resource type to begin:

  ul.type
    li v-for="(type, key) in $options.types"
      router-link :to="key"
        i.icon.fa.fa-fw :class="type.icon"
        .body
          .name() {{ type.name }}
          | {{ type.desc }}

  p 
    | ReaPack also supports automation items, MIDI note names, project &
      track templates and web interfaces packages which don't have a dedicated
      ReaTeam repository at this time.

  p Have a question? Come discuss in the <a href="https://forum.cockos.com/showthread.php?t=169127" target="_blank">development thread</a> on the REAPER forum!
</template>

<script lang="coffee">
import * as Types from '../types'

export default
  types: {
    reascript: Types.reascript,
    jsfx:      Types.jsfx,
    theme:     Types.theme
    langpack:  Types.langpack,
    extension: Types.extension,
  }
</script>

<style lang="sass">
@use 'config'

.type
  margin-left: 0

  li
    background-color: config.$table-row-even
    border-radius: 7px
    border: 1px solid config.$foreground
    list-style-type: none
    margin-bottom: config.$margin

  a
    align-items: center
    color: config.$foreground
    display: flex
    font-weight: normal
    padding: config.$padding
    text-decoration: none

  .icon
    font-size: 2.3em
    flex: 0 0 auto

  .body
    flex: 1 1 auto
    margin-left: 5px

  .name
    font-size: 1.3em
    text-decoration: underline
    font-weight: bold
</style>
