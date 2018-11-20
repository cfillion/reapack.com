<template lang="slim">
.select-type
  p Select a primary REAPER resource type to begin:

  ul.type
    li v-for="(type, repo) in types"
      router-link :to="repo"
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
Types = require '../types'

module.exports =
  name: 'select-type'
  data: -> { types: Types }
</script>

<style lang="sass">
@import 'config'

.type
  margin-left: 0

  li
    background-color: $table-row-even
    border-radius: 7px
    border: 1px solid $foreground
    list-style-type: none
    margin-bottom: $margin

  a
    display: block
    text-decoration: none
    font-weight: normal
    padding: $padding
    display: flex
    align-items: center

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
