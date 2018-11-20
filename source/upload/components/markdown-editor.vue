<template lang="slim">
tab-bar
  tab name='Write'
    textarea(rows=12 :id="id" :value="value" :placeholder="placeholder"
      @input=="$emit('input', $event.target.value)")
    slot
  tab name='Preview' @activated=="refreshPreview"
    p v-html="preview"
</template>

<script lang="coffee">
CommonMark = require 'commonmark'

TabBar     = require './tabbar.vue'
Tab        = require './tab.vue'

reader = new CommonMark.Parser
writer = new CommonMark.HtmlRenderer safe: true

module.exports =
  components: { TabBar, Tab }
  props:
    id: String
    value: String
    placeholder: String
    disableImages: Boolean
  data: ->
    preview: ''
  methods:
    refreshPreview: ->
      parsed = reader.parse @value || @placeholder || ''
      walker = parsed.walker()

      if @disableImages
        while event = walker.next()
          node = event.node

          if event.entering && node.type == 'image'
            node._type = 'link'

      @preview = writer.render parsed
</script>

<style lang="sass" scoped>
textarea
  margin-top: 0
</style>
