<template lang="slim">
form.editor v-if="package && package.type" @submit.prevent="submit"
  h2 Package editor ({{ package.type.name }})

  p
    | Fill this form to submit a new package or update an existing package on
      the <a :href="repoUrl" target="_blank">{{ package.type.repo }}</a> repository.

  p.error v-if="index.error"
    strong> Error:
    | Could not to load the content of the repository. {{ index.error }}

  p.error v-if="errors.length" ref="errors"
    strong Please correct the following error(s):
    ul: li v-for="error in errors" {{ error }}

  h3 Metadata
  p Customize how your package will appear in ReaPack.

  p.autocomplete
    field-label target="name" Display name
    input#name (
      ref="nameInput"
      type="text" autofocus=true v-model.trim="package.name"
      :placeholder=="'Example: ' + package.type.placeholders.name"
      @input="matchingPackages = index.similarPackages(package.name)"
    )
    dropdown-menu (
      :show="matchingPackages.length > 0" :items="matchingPackages"
      :button="$refs.nameInput"
      @input="loadExisting($event)" @leave="matchingPackages = []"
    )
      template slot="item" slot-scope="slotProps"
        strong() {{ slotProps.item.name }}
        br
        | v{{ slotProps.item.latest.name }} by
          {{ slotProps.item.latest.author || 'Unknown author' }}
          – {{ slotProps.item.latest.fileNodes.length }} file(s)
          – {{ slotProps.item.category }}
    | Choose a brief name to describe your package.

  p
    field-label target="category" Category
    input-dropdown#category v-model="package.category" :choices="index.categories"
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
    button.main type="submit" :disabled="!dirty || !canSubmit"
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
import Index from '../index'

import DropdownMenu from './dropdown-menu.vue'
import FieldLabel from './field-label.vue'
import InputDropdown from './input-dropdown.vue'
import InputMarkdown from './input-markdown.vue'
import PackageFiles from './package-files.vue'
import PackageLinks from './package-links.vue'

export default
  components: {
    DropdownMenu, FieldLabel, InputDropdown, InputMarkdown,
    PackageFiles, PackageLinks,
  }
  data: ->
    dirty: false
    errors: []
    index: new Index
    matchingPackages: []
    package: null
  computed:
    repoUrl: -> "https://github.com/#{@package.type.repo}"
    aboutPlaceholder: ->
      name = @package.name.trim()
      name = 'Package name' unless name
      "# #{name}\n\nLonger description of the package here.\n\n
      Key features:\n\n- Lorem ipsum\n- Dolor sit amet\n- Consectetur adipiscing elit"
    canSubmit: -> @package.name && @package.category && @package.version
  methods:
    setPackage: (@package) ->
      Vue.nextTick => @dirty = false
    reset: ->
      type = Types[@$route.params.type]

      if type?.repo
        @setPackage new Package(type)
        @index.load type.repo
    loadExisting: (pkgInfo) ->
      #return unless confirm "Load package '#{pkgInfo.name}'?
      #  Unsaved changes will be lost."

      pkgInfo.load()
      .then (pkg) => @setPackage pkg
      .catch (error) => alert error
    onBeforeUnload: (event) ->
      if @dirty
        event.preventDefault()
        event.returnValue = ''
    submit: ->
      @errors = @package.validateAll()

      if @errors.length
        Vue.nextTick => @$refs.errors.scrollIntoView()
        return
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

<style lang="sass">
.autocomplete
  position: relative

  .dropdown-menu
    width: 100%
</style>
