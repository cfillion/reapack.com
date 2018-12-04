export default
  data: ->
    drag: false
  methods:
    onDragOver: (event) ->
      return unless @isFileDragEvent event
      event.preventDefault()
      event.stopPropagation()
      @drag = true
    onDragLeave: ->
      @drag = false
    onDrop: (event) ->
      return unless @drag
      event.preventDefault()
      event.stopPropagation()
      @drag = false

      for localFile in event.dataTransfer.files
        @loadLocalFile localFile
    isFileDragEvent: (event) ->
      for item in event.dataTransfer.items
        return true if item.kind == 'file'
      false
