<template lang="slim">
.dialog-overlay.open v-if="progress": .dialog.progress :class=="{ done: progress.done }"
  .icon
    i.fa.fa-check-circle v-if="progress.done"
    i.fa.fa-spin.fa-circle-o-notch v-else=""
  .desc() {{ progress.desc }}
  .error v-if="progress.error"
    p
      strong> Error:
      | {{ progress.error.message }}
    p: button type="button" @click="close" Close
  .legend v-else-if="progress.legend" {{ progress.legend }}
  .buttons v-if="progress.buttons.length"
    button v-for="button in progress.buttons" type="button" @click="button.click"
      i.fa> :class="button.icon"
      | {{ button.label }}
</template>

<script lang="coffee">
export class Progress
  constructor: (@desc) ->
    @error = ''
    @legend = ''
    @buttons = []
    @done = false

export default
  props:
    progress: Progress
  methods:
    close: -> @$emit 'close'
</script>

<style lang="sass" scoped>
@import 'config'

.progress
  text-align: center

  &.done
    color: $success

.icon
  font-size: 6em

.desc
  font-size: 2em

.error, .buttons
  margin-top: 20px

.buttons button:not(:last-child)
  margin-right: 7px
</style>
