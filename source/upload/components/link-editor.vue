<template lang="slim">
.link-editor
  ul v-if="links.length > 0"
    li v-for="(link, i) in links"
      i.fa> :class='link.icon'
      a> :href="link.url" target="_blank" :title='link.url'
        | {{ link.name || link.url }}
      a href="javascript:;" title="Remove this link" @click="removeLink(i)"
        i.fa.fa-trash

  form @submit.prevent="submit"
    .type-col
      field-label target="link-type" Type
      select#link-type v-model='typeName'
        option value='link' Website
        option value='screenshot' Screenshot
        option value='donation' Donation
    .name-col
      field-label target="link-name" optional=true Name
      input#link-name v-model='name' :placeholder=="'Example: ' + type.namePlaceholder"
    .url-col
      field-label target="link-url" URL
      input#link-url type='url' v-model='url' :placeholder=="'Example: ' + type.urlPlaceholder"
    .btn-col
      br
      button Add link
</template>

<script lang="coffee">
LinkTypes =
  link:
    icon: 'fa-link'
    namePlaceholder: 'ReaPack website'
    urlPlaceholder: 'https://reapack.com'
  screenshot:
    icon: 'fa-picture-o'
    namePlaceholder: 'Docked mode'
    urlPlaceholder: 'https://i.imgur.com/4xPMV9J.gif'
  donation:
    icon: 'fa-paypal'
    namePlaceholder: 'Donate via PayPal'
    urlPlaceholder: 'https://paypal.me/cfillion'

module.exports =
  data: -> { links: [], typeName: 'screenshot', name: '', url: '' }
  computed:
    type: -> LinkTypes[@typeName]
  methods:
    removeLink: (i) -> @links.splice(i, 1)
    submit: ->
      type = @type
      name = @name.trim()
      url = @url.trim()

      return unless type && url

      @links.push {type: @typeName, icon: type.icon, name: name, url: url}
      @name = @url = ''
</script>

<style lang="sass">
.link-editor
  ul
    list-style-type: none
    margin-left: 0

  form
    display: flex

  input
    margin: 0

  .name-col, .url-col, .btn-col
    margin-left: 7px

  .name-col
    flex: 1 1 35%

  .url-col
    flex: 1 1 65%

  .btn-col
    flex: 0 0 auto
</style>
