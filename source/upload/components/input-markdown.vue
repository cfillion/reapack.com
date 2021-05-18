<template lang="slim">
tab-bar
  tab name="Write"
    textarea(rows=12 :id="id" :value="value" :placeholder="placeholder"
      @input=="$emit('input', $event.target.value)")
    slot
  tab name='Preview' @activated="refreshPreview" v-html="preview"
</template>

<script lang="coffee">
import { Parser, HtmlRenderer } from 'commonmark'

import TabBar from './tabbar.vue'
import Tab from './tab.vue'

reader = new Parser
writer = new HtmlRenderer safe: true

export default
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
