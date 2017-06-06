nodes = document.getElementsByClassName 'index'
copyAll = document.getElementsByClassName('copyAll')[0]
copied = document.getElementsByClassName('copied')[0]

for i in [0...nodes.length]
  nodes[i].addEventListener 'click', (event) -> event.preventDefault()

cbs = [
  new Clipboard(nodes, target: (node) -> node.firstChild),

  new Clipboard(copyAll, text: ->
    urls = []
    for i in [0...nodes.length]
      urls.push nodes[i].firstChild.innerText
    urls.join "\n"
  ),
]

flashTimeout = null
flashCopy = ->
  window.clearTimeout flashTimeout if flashTimeout

  copied.classList.remove 'hidden'

  flashTimeout = window.setTimeout (->
    copied.classList.add 'hidden'
    flashTimeout = null
  ), 2000

cb.on 'success', flashCopy for cb in cbs
