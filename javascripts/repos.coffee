nodes = document.getElementsByClassName 'index'

for i in [0...nodes.length]
  nodes[i].addEventListener 'click', (event) -> event.preventDefault()

new Clipboard nodes, target: (node) -> node.firstChild
