selected_dl = undefined

startDownload = (donated) ->
  dlg = document.getElementById 'thank-you'
  dlg.classList.add 'done'
  dlg.classList.add 'donated' if donated
  window.location = selected_dl.href

setPaypalButtonID = (btn_id) ->
  btn = PayPal.Donation.Button
    # env: 'sandbox'
    # hosted_button_id: 'SG7CEFWQGFCJQ'
    env: 'production'
    hosted_button_id: btn_id
    image:
      src:   'https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif'
      title: 'PayPal - The safer, easier way to pay online!'
      alt:   'Donate with PayPal button'
    onComplete: -> startDownload(true)
  btn.render('#paypal-button')

initPaypalButton = ->
  promise = fetch '/api/currency'
  promise.then (response) -> response.text().then setPaypalButtonID
  promise.catch -> setPaypalButtonID 'X6L6TH9ELXSG2'

getPaypalButton = ->
  document.querySelector '#paypal-button img'

for dl in document.getElementsByClassName 'dl'
  dl.addEventListener 'click', (e) ->
    filename = this.href.split('/').pop()
    ga 'send',
      hitType: 'event'
      eventCategory: 'Downloads'
      eventAction: 'start'
      eventLabel: filename

    selected_dl = this

    platform = this.closest('.platform').querySelector('h3')
    desc = document.getElementById 'dl-desc'
    desc.innerText = "#{platform.firstChild.nodeValue} #{this.innerText}"
    document.getElementById('dl-fn').innerText = filename

    manual = document.getElementById 'manual'
    manual.href = selected_dl.href

    dlg = document.getElementById 'thank-you'
    dlg.classList.add 'open'
    if dlg.classList.contains 'donated'
      startDownload true
    else
      dlg.classList.remove 'done'

    e.preventDefault()

    if not getPaypalButton()
      initPaypalButton()

for dialog in document.getElementsByClassName 'dialog-overlay'
  dialog.addEventListener 'click', (e) =>
    return unless e.target == dialog or e.target.classList.contains('close')
    dialog.classList.remove 'open'

  close = document.createElement 'span'
  close.classList.add 'close'
  close.appendChild document.createTextNode('×')
  dialog.firstChild.prepend close

document.getElementsByClassName('donate')[0].addEventListener 'click', (e) ->
  ga 'send',
    hitType: 'event'
    eventCategory: 'Donate'
    eventAction: 'click'
    eventLabel: this.textContent.trim()

  if paypal = getPaypalButton()
    paypal.click()
    e.preventDefault()

document.getElementsByClassName('sponsor')[0].addEventListener 'click', ->
  ga 'send',
    hitType: 'event'
    eventCategory: 'Donate'
    eventAction: 'sponsor'

document.getElementById('direct').addEventListener 'click', (e) ->
  ga 'send',
    hitType: 'event'
    eventCategory: 'Downloads'
    eventAction: 'direct'

  startDownload(false)
  e.preventDefault()
