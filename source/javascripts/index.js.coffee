nodes = document.getElementsByClassName 'dl'

for node in nodes
  node.addEventListener 'click', ->
    file = this.href.split('/').pop()

    ga 'send', {
      hitType: 'event',
      eventCategory: 'Downloads',
      eventAction: 'start',
      eventLabel: file,
    }
