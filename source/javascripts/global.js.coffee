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

document.getElementsByClassName('donate')[0].addEventListener 'click', ->
  ga 'send', {
    hitType: 'event',
    eventCategory: 'Donate',
    eventAction: 'click',
    eventLabel: this.textContent.trim()
  }
