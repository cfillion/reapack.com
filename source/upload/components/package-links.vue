<template lang="slim">
.link-editor.group
  ul v-if="links.length > 0"
    li v-for="(link, i) in sortedLinks"
      i.fa.fa-fw> :class="link.type.icon" :title="link.type.name"
      a> :href="link.url" target="_blank" :title="link.url"
        | {{ link.name || link.url }}
      a href="javascript:;" title="Remove this link" @click="removeLink(i)"
        i.fa.fa-trash

  form @submit.prevent="submit"
    div
      field-label target="link-type" Type
      input-dropdown#link-type v-model="type" :choices="types"
    div
      field-label target="link-name" optional=true Name
      input#link-name (
        type="text" v-model.trim="name"
        :placeholder=="'Example: ' + type.namePlaceholder"
      )
    div
      field-label target="link-url" URL
      input#link-url (
        type="url" v-model.trim="url"
        :placeholder=="'Example: ' + type.urlPlaceholder"
      )
    div
      button type="submit" Add link
</template>

<script lang="coffee">
LinkTypes = [
    tag: 'link'
    icon: 'fa-link'
    name: 'Website'
    namePlaceholder: 'ReaPack website'
    urlPlaceholder: 'https://reapack.com'
  ,
    tag: 'screenshot',
    icon: 'fa-picture-o'
    name: 'Screenshot'
    namePlaceholder: 'Docked mode'
    urlPlaceholder: 'https://i.imgur.com/4xPMV9J.gif'
  ,
    tag: 'donation'
    icon: 'fa-paypal'
    name: 'Donation'
    namePlaceholder: 'Donate via PayPal'
    urlPlaceholder: 'https://paypal.me/cfillion'
]

import FieldLabel from './field-label.vue'
import InputDropdown from './input-dropdown.vue'

export default
  components: { FieldLabel, InputDropdown }
  props:
    links:
      type: Array
      required: true
  data: ->
    type: LinkTypes[1]
    name: ''
    url: ''
  computed:
    types: -> LinkTypes
    sortedLinks: ->
      @links.sort (a, b) -> LinkTypes.indexOf(a.type) - LinkTypes.indexOf(b.type)
  methods:
    removeLink: (i) -> @links.splice(i, 1)
    submit: ->
      return unless @url

      @links.push {type: @type, name: @name, url: @url}
      @name = @url = ''
</script>

<style lang="sass">
.link-editor
  ul
    list-style-type: none
    margin-left: 0

  form
    display: grid
    align-items: end
    grid-template-columns: 150px 1.2fr 2fr auto
    grid-column-gap: 7px

#link-type
  width: 100%
</style>
