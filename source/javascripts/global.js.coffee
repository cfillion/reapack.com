for dl in document.getElementsByClassName 'dl'
  dl.addEventListener 'click', ->
    ga 'send',
      hitType: 'event'
      eventCategory: 'Downloads'
      eventAction: 'start'
      eventLabel: this.href.split('/').pop()

document.getElementsByClassName('donate')[0].addEventListener 'click', ->
  ga 'send',
    hitType: 'event'
    eventCategory: 'Donate'
    eventAction: 'click'
    eventLabel: this.textContent.trim()
