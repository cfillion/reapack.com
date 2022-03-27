for dl in document.getElementsByClassName 'dl'
  dl.addEventListener 'click', ->
    ga 'send',
      hitType: 'event'
      eventCategory: 'Downloads'
      eventAction: 'start'
      eventLabel: this.href.split('/').pop()

document.getElementsByClassName('donate')[0].addEventListener 'click', (e) ->
  ga 'send',
    hitType: 'event'
    eventCategory: 'Donate'
    eventAction: 'click'
    eventLabel: this.textContent.trim()

  if paypal = document.querySelector '#paypal-button img'
    paypal.click()
    e.preventDefault()

btn = PayPal.Donation.Button
  env: 'production'
  hosted_button_id: 'X6L6TH9ELXSG2'
  image:
    src: 'https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif'
    title: 'PayPal - The safer, easier way to pay online!'
    alt: 'Donate with PayPal button'
btn.render('#paypal-button')
