<template lang="slim">
.editor v-if="package && package.type"
  h2 Package editor ({{ package.type.name }})

  p
    | Fill this form to submit a new package or update an existing package on
      the <a :href="repoUrl" target="_blank">{{ package.type.repo }}</a> repository.

  h3 Metadata
  p Customize how your package will appear in ReaPack.

  p
    field-label target="name" Display name
    input#name (
      type="text" autofocus=true v-model.trim="package.name"
      :placeholder=="'Example: ' + package.type.placeholders.name"
    )
    | Choose a brief name to describe your package.

  p
    field-label target="category" Category
    input-dropdown#category v-model="package.category" :choices='["Hello", "World", "Lorem ipsum dolor sit amet"]'
    | Select the most appropriate category.

  p
    field-label target="author" Author name
    input#author (
      type="text" v-model.trim="package.author"
      placeholder="Example: John Doe or jdoe"
    )
    | Type your name or username. This field will be searchable.

  p
    field-label target="about" optional=true Documentation
    input-markdown#about (
      disable-images=true v-model.trim="package.about"
      :placeholder="aboutPlaceholder"
    )
      | Write a longer description of your package along with usage instructions.
        This field uses the <a href="https://commonmark.org/" target="_blank">CommonMark</a>
        syntax.

  div
    field-label target="link-url" optional=true External links
    package-links :links="package.links"

  h3 Contents
  p Release a new version or edit the current version. Previous versions are preserved.

  p
    field-label target="version" Version number
    input#version (
      type="text" v-model.trim="package.version"
      placeholder="Examples: 1.0, 1.2.3, 1.2alpha, 1.2.3pre4…"
    )
    | Increase the version number to push changes to existing users.
      Add letters to create a pre-release (e.g. 4.2beta1).

  div
    field-label Provided files
    package-files :package="package"

  p
    field-label target="changelog" optional=true Changelog
    textarea#changelog (
      rows=5 v-model.trim="package.changelog"
      :placeholder=="'Example:\n' + package.type.placeholders.changelog"
    )
    | Changelog for the current version only. Displayed when installing or
      updating the package.

  p
    button.main type="submit" disabled=true
     | Create pull request on {{ package.type.repo }}

div v-else=""
  p
    ' This resource type does not exist.
    router-link to="/" Select another resource type.
</template>

<script lang="coffee">
import Vue from 'vue'

import * as Types from '../types'
import Package from '../package'

import FieldLabel from './field-label.vue'
import InputDropdown from './input-dropdown.vue'
import InputMarkdown from './input-markdown.vue'
import PackageFiles from './package-files.vue'
import PackageLinks from './package-links.vue'

export default
  components: { FieldLabel, InputDropdown, InputMarkdown, PackageFiles, PackageLinks }
  data: ->
    package: null
    dirty: false
  computed:
    repoUrl: -> "https://github.com/#{@package.type.repo}"
    indexUrl: -> "#{@repoUrl}/raw/master/index.xml"
    aboutPlaceholder: ->
      name = @package.name.trim()
      name = 'Package name' unless name
      "# #{name}\n\nLonger description of the package here.\n\n
      Key features:\n\n- Lorem ipsum\n- Dolor sit amet\n- Consectetur adipiscing elit"
  methods:
    reset: ->
      type = Types[@$route.params.type]
      @package = new Package(type if type?.repo)
      Vue.nextTick => @dirty = false
    onBeforeUnload: (event) ->
      if @dirty
        event.preventDefault()
        event.returnValue = ''
  watch:
    '$route.params.type': -> @reset()
    package:
      deep: true
      handler: -> @dirty = true
  created: ->
    window.addEventListener 'beforeunload', @onBeforeUnload
  beforeDestroy: ->
    window.removeEventListener 'beforeunload', @onBeforeUnload
  beforeRouteEnter: (to, from, next) -> next (vm) -> vm.reset()
  beforeRouteLeave: (to, from, next) ->
    if !@dirty || window.confirm \
        'Do you really want to leave? Data you have entered will be lost.'
      next()
    else
      next(false)
</script>
