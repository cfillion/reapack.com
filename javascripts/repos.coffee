nodes = document.getElementsByClassName 'index'

for i in [0...nodes.length]
  node = nodes[i]
  do (node) ->
    node.addEventListener 'click', (event) ->
      if document.body.createTextRange
        range = document.body.createTextRange()
        range.moveToElementText(node)
        range.select()
      else if window.getSelection
        selection = window.getSelection()
        range = document.createRange()
        range.selectNodeContents(node)
        selection.removeAllRanges()
        selection.addRange(range)

      event.preventDefault()
