<template lang="slim">
.editor v-if="type"
  h2 Package editor ({{ type.name }})

  p
    | Fill this form to submit a new package or update an existing package on
      the <a :href="repoUrl" target="_blank">{{ type.repo }}</a> repository.

  h3 Metadata
  p Customize how your package will appear in ReaPack.

  p
    field-label target='name' Display name
    input#name autofocus=true v-model='name' :placeholder=="'Example: ' + type.placeholders.name"
    | Choose a brief name to describe your package.

  p
    field-label target='category' Category
    select#category v-model='category'
      option Track Properties
    | Select the most appropriate category.

  p
    field-label target='author' Author name
    input#author v-model='author' placeholder="Example: John Doe or jdoe"
    | Type your name or username. This field will be searchable.

  p
    field-label target='about' optional=true Documentation
    tabbar
      tab name='Write'
        textarea#about v-model='about' :placeholder="aboutPlaceholder" rows=12
        | Write a longer description of your package along with usage
          instructions. This field uses the 
          <a href="https://commonmark.org/" target="_blank">CommonMark</a>
          syntax.
      tab name='Preview' @activated=="refreshPreview"
        p v-html="aboutPreview"

  div
    field-label target='link-url' optional=true External links
    .group: link-editor

  h3 Contents
  p Release a new version or edit the current version. Previous versions are preserved.

  p
    field-label target='version' Version number
    input#version placeholder="Examples: 1.0, 1.2.3, 1.2alpha, 1.2.3pre4..."
    | Increase the version number to push changes to existing users.
      Add letters to create a pre-release (e.g. 4.2beta1).

  p
    field-label target='changelog' optional=true Changelog
    textarea#changelog rows=5 :placeholder=="'Example:\n' + type.placeholders.changelog"

  div
    label Provided files
    .group
      p
        i.fa.fa-plus>
        | Add a file

  form: button.main disabled=true Create pull request

div v-else=""
  p
    ' This resource type does not exist.
    router-link to="/" Select another resource type.
</template>

<script lang="coffee">
Types = require '../types'
CommonMark = require 'commonmark'

module.exports =
  components:
    'link-editor': require('./link-editor.vue')
  data: ->
    category: ''
    name: ''
    author: ''
    about: ''
    aboutPreview: ''
  computed:
    type: -> Types[@$route.params.type]
    repoUrl: -> "https://github.com/#{@type.repo}"
    indexUrl: -> "#{@repoUrl}/raw/master/index.xml"
    aboutPlaceholder: ->
      name = @name.trim()
      name = 'Package name' unless name
      "# #{name}\n\nLonger description of the package name here.\n\n
      Key features:\n\n- Lorem ipsum\n- Dolor sit amet\n- Consectetur adipiscing elit"
  methods:
    refreshPreview: ->
      reader = new CommonMark.Parser
      writer = new CommonMark.HtmlRenderer safe: true
      parsed = reader.parse if @about then @about else @aboutPlaceholder
      walker = parsed.walker()

      # disable images
      while event = walker.next()
        node = event.node

        if event.entering && node.type == 'image'
          node._type = 'link'

      @aboutPreview = writer.render parsed
  # beforeRouteLeave: (to, from, next) ->
  #   if window.confirm 'Do you really want to leave? Data you have entered will be lost.'
  #     next()
  #   else
  #     next(false)
</script>
