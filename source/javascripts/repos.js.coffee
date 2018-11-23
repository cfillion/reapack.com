nodes = document.getElementsByClassName 'index'
copyAll = document.getElementsByClassName('copyAll')[0]
copied = document.getElementsByClassName('copied')[0]

for node in nodes
  node.addEventListener 'click', (event) ->
    event.preventDefault()

    ga 'send', {
      hitType: 'event',
      eventCategory: 'Repositories',
      eventAction: 'copy',
      eventLabel: this.href,
    }

copyAll.addEventListener 'click', ->
  ga 'send', {
    hitType: 'event',
    eventCategory: 'Repositories',
    eventAction: 'copy',
    eventLabel: 'all',
  }

cbs = [
  new Clipboard(nodes, target: (node) -> node.firstChild),

  new Clipboard(copyAll, text: ->
    (node.firstChild.innerText for node in nodes).join "\n"
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
