<template lang="slim">
.file-content.drop-target
  .drag-overlay v-if="drag"
</template>

<script lang="coffee">
import CodeMirror from 'codemirror'
import 'codemirror/mode/meta'
import 'codemirror/lib/codemirror.css'
import 'codemirror/theme/bespin.css'

import 'codemirror/addon/display/rulers'
import 'codemirror/addon/edit/trailingspace'
import 'codemirror/addon/selection/active-line'

import 'codemirror/mode/css/css'
import 'codemirror/mode/htmlmixed/htmlmixed'
import 'codemirror/mode/javascript/javascript'
import 'codemirror/mode/lua/lua'
import 'codemirror/mode/properties/properties'
import 'codemirror/mode/python/python'
import 'codemirror/mode/xml/xml'

CodeMirror.modeInfo.push [
  { mode: 'properties', ext: ['reaperlangpack', 'reapertheme', 'reascale'] }
]...

export default
  data: ->
    drag: false
  props:
    filename: String
    header: String
    value: String
  mounted: ->
    @codemirror = CodeMirror @$el,
      lineNumbers: true
      showTrailingSpace: true
      styleActiveLine: true
      tabSize: 2
      theme: 'bespin'
      rulers: [
        { color: '#3b332e', column: 80, width: '0.5em' }
      ]

    @updateHeader()
    @updateContent()
    @updateMode()

    @codemirror.on 'change', @contentChanged
    @codemirror.on 'dragover', => @drag = true
    @codemirror.on 'dragleave', => @drag = false
    @codemirror.on 'drop', (cm, e) =>
      e.stopPropagation()
      @drag = false
  beforeDestroy: ->
    @codemirror.getWrapperElement().remove()
  watch:
    header: -> @updateHeader()
    value: -> @updateContent()
    filename: -> @updateMode()
  methods:
    contentRange: ->
      start = if range = @headerMark?.find()
        range.to
      else
        {line: 0, ch: 0}

      end = {line: Infinity}

      [start, end]
    updateHeader: ->
      replaceFrom = {line: 0, ch: 0}
      replaceTo = {line: 0, ch: 0}

      if range = @headerMark?.find()
        [replaceFrom, replaceTo] = [range.from, range.to]
        @headerMark.clear()

      @codemirror.replaceRange @header, replaceFrom, replaceTo

      headerEnd = @codemirror.posFromIndex @header.length
      @headerMark = @codemirror.markText {line: 0, ch: 0}, headerEnd,
        className: 'metadata'
        inclusiveLeft: true
        readOnly: true
    updateContent: ->
      if @eatChange
        @eatChange = false
        return

      @codemirror.replaceRange @value, @contentRange()...
    contentChanged: (_, change) ->
      return unless change.origin # ignore non-user changes

      @eatChange = true
      newValue = @codemirror.getRange @contentRange()...
      @$emit 'input', newValue
    updateMode: ->
      newMode = CodeMirror.findModeByFileName(@filename.toLowerCase())?.mode
      newMode = null unless CodeMirror.modes[newMode]
      oldMode = @codemirror.getOption 'mode'

      @codemirror.setOption 'mode', newMode if newMode != oldMode
</script>

<style lang="sass">
@use 'sass:color'
@use 'upload-mixins'

.CodeMirror
  +upload-mixins.input-field
  font-size: 14px
  text-shadow: none
  z-index: 0

.cm-trailingspace
  background-color: color.scale(red, $alpha: -50%)

.metadata
  color: #908960 !important
  font-weight: bold
</style>
