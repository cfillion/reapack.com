<template lang="slim">
.file-content.drop-target
  .drop-overlay v-if="drop"
</template>

<script lang="coffee">
import CodeMirror from 'codemirror'
import 'codemirror/mode/meta'
import 'codemirror/lib/codemirror.css'
import 'codemirror/theme/bespin.css'

import 'codemirror/addon/display/fullscreen'
import 'codemirror/addon/display/fullscreen.css'
import 'codemirror/addon/display/rulers'
import 'codemirror/addon/edit/trailingspace'
import 'codemirror/addon/selection/active-line'

import 'codemirror/mode/lua/lua'
import 'codemirror/mode/python/python'

export default
  data: ->
    drop: false
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
      extraKeys:
        'F11': (cm) ->
          cm.setOption 'fullScreen', not cm.getOption('fullScreen')
        'Esc': (cm) ->
          cm.setOption 'fullScreen', false if cm.getOption 'fullScreen'

    @updateHeader()
    @updateContent()
    @updateMode()

    @codemirror.on 'change', @contentChanged
    @codemirror.on 'dragover', => @drop = true
    @codemirror.on 'dragleave', => @drop = false
    @codemirror.on 'drop', => @drop = false
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
      newMode = CodeMirror.findModeByFileName(@filename)?.mode
      newMode = null unless CodeMirror.modes[newMode]
      oldMode = @codemirror.getOption 'mode'

      @codemirror.setOption 'mode', newMode if newMode != oldMode
</script>

<style lang="sass">
@import 'upload-mixins'

.CodeMirror
  +input-field
  font-size: 14px
  height: auto
  text-shadow: none
  z-index: 0

.CodeMirror-scroll
  min-height: 300px

.CodeMirror-fullscreen
  border: 0
  border-radius: unset

.cm-trailingspace
  background-color: transparentize(red, 0.5)

.metadata
  font-weight: bold
</style>
