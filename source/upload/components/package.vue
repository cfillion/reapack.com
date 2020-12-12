<template lang="slim">
form.editor v-if="package && package.type" @submit.prevent="submit"
  progress-overlay :progress="progress" @close="progress = null"

  pull-requests :list="pullRequests" :repo="package.type.repo"

  .user
    template v-if="user"
      ' Logged in as
      a> :href="user.html_url" target="blank"
        img.avatar> :src="user.avatar_url"
        | {{ user.login }}
      button type="button" @click="logout" Log out
    button type="button" v-else="" @click="login"
      i.fa.fa-github>
      | Login via GitHub

  h2() {{ package.type.name }}

  p
    | Use this page to submit a new package or update an existing package on
      the <a :href="repoUrl" target="_blank">{{ package.type.repo }}</a>
      repository. A GitHub account is required. Your changes will be reviewed
      before publication. You should be the original author of the resource you
      are releasing.

  p
    ' A package is defined by a "package file" containing the
    a> (
      href="https://github.com/cfillion/reapack-index/wiki/Packaging-Documentation"
      target="_blank"
    ) metadata header
    ' for reapack-index (software used internally on the repository).
      This metadata header is automatically generated from the data entered here.

    | A single package can install more than one file.

  p
    ' {{ package.type.name }} package files ({{ packageExtensions }})
    template v-if="package.type.metapackage"
      ' remain on the repository and are not installed.
    template v-else=""
      ' are marked for installation by default.

    template v-if="package.type.defaultExternal"
      | Click on the "Add file" button (near the bottom of this form) and
        paste the download URL of your {{ package.type.defaultExtension }}.
        This URL should be unique for every version to allow downgrading.
        Consider hosting your files on the <a href="https://stash.reaper.fm"
        target="_blank">REAPER stash</a>.
    template v-else=""
      | Insert the main code of your {{ package.type.casualName }} below the generated
        metadata header.

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
      :button="$refs.nameInput" legend="Matching packages (click to load and edit an existing package):"
      @input="loadExisting($event)" @leave="matchingPackages = []"
    )
      template v-slot:item="{ item }"
        strong() {{ item.name }}
        br
        | v{{ item.latest.name }} by {{ item.latest.author || 'Unknown author' }}
          – {{ item.latest.fileNodes.length }} file{{item.latest.fileNodes.length == 1 ? '' : 's' }}
          – {{ item.category }}
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
    | Type your name or username. This field is searchable along with the
      package name and category.

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
      type="text" v-model.trim="package.version" pattern="[0-9][0-9a-z\./_+-]*"
      placeholder="Examples: 1.0, 1.2.3, 1.2alpha, 1.2.3pre4…"
    )
    ' Increase the version number to push changes to existing users.
      Add letters to create a
    span.help> title="Pre-releases are not automatically installed or updated to (from a stable release) by default." pre-release
    | (e.g. 4.2beta1).

  div
    field-label Provided files
    package-files (
      :package="package"
      :fullscreen="fullscreen" @fullscreen="fullscreen = $event"
    )

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
    span.submit-legend
      | Please double-check your package before submitting.

div v-else=""
  p
    ' This resource type does not exist.
    router-link to="/" Select another resource type.
</template>

<script lang="coffee">
import Vue from 'vue'

import * as Types from '../types'
import * as GitHub from '../github'
import Index from '../index'
import Package from '../package'
import { UploadSource } from '../file'
import { fileListToTree } from '../file-utils'

import DropdownMenu from './dropdown-menu.vue'
import FieldLabel from './field-label.vue'
import InputDropdown from './input-dropdown.vue'
import InputMarkdown from './input-markdown.vue'
import PackageFiles from './package-files.vue'
import PackageLinks from './package-links.vue'
import ProgressOverlay, { Progress } from './progress-overlay.vue'
import PullRequests from './pull-requests.vue'

export default
  components: {
    DropdownMenu, FieldLabel, InputDropdown, InputMarkdown, ProgressOverlay,
    PackageFiles, PackageLinks, PullRequests,
  }
  data: ->
    dirty: false
    errors: []
    fullscreen: false
    index: new Index
    matchingPackages: []
    package: null
    progress: null
    pullRequests: []
    user: null
  computed:
    repoUrl: -> "https://github.com/#{@package.type.repo}"
    aboutPlaceholder: ->
      name = @package.name.trim()
      name = 'Package name' unless name
      "# #{name}\n\nLonger description of the package here.\n\n
      Key features:\n\n- Lorem ipsum\n- Dolor sit amet\n- Consectetur adipiscing elit"
    packageExtensions: -> @package.type.extensions.join ', '
    canSubmit: ->
      !@fullscreen && @package.name && @package.category && @package.version
  methods:
    setPackage: (@package) ->
      Vue.nextTick => @dirty = false
    reset: ->
      type = Types[@$route.params.type]

      if type?.repo
        @setPackage new Package(type)
        @index.load type.repo

      @updatePullRequests()
    loadExisting: (pkgInfo) ->
      return unless confirm "Load package '#{pkgInfo.name}' from
        #{@package.type.repo}? Unsaved changes will be lost."

      @progress = new Progress 'Loading package...'

      pkgInfo.load()
      .then (pkg) =>
        @setPackage pkg
        @progress = null
      .catch (error) => @progress.error = error
    onBeforeUnload: (event) ->
      if @dirty
        event.preventDefault()
        event.returnValue = ''
    updatePullRequests: ->
      @pullRequests = if @user
        await GitHub.getPullRequests @package.type.repo, @user
      else
        []
    login: ->
      @user = await GitHub.login()
    logout: ->
      GitHub.logout()
      @user = null
    submit: ->
      @errors = @package.validateAll()

      if @errors.length
        Vue.nextTick => @$refs.errors.scrollIntoView()
        return
      else if process.env.NODE_ENV != 'production'
        return unless confirm 'Validation passed. Create test pull request?'

      try
        @progress = new Progress 'Waiting for GitHub authorization...'
        @progress.legend = 'Click on the button below to open the GitHub
          authorization page in another tab.'
        @progress.buttons = [
          icon:  'fa-github'
          label: 'Login via GitHub'
          click: GitHub.openLoginPage
        ]
        @user = await GitHub.login()
        @progress.buttons = []

        @progress.desc = "Forking #{@package.type.repo}..."
        @progress.legend = "This may take a while.
          Please keep this page open until it's done."
        repoName = @package.type.repo
        forkName = await GitHub.createFork repoName

        @progress.desc = 'Uploading files...'
        head = await GitHub.getHead repoName
        commit = await GitHub.upload forkName, head, @package

        @progress.desc = 'Creating pull request...'
        branchName = "reapack.com_upload-#{+new Date}"
        branch = await GitHub.createBranch forkName, branchName, commit

        prRepo = if process.env.NODE_ENV == 'production' then repoName else forkName
        pr = await GitHub.createPullRequest prRepo,
          title: commit.message.split('\n')[0]
          body: @package.changelog
          head: "#{@user.login}:#{branchName}"
          base: 'master'

        @progress.desc = 'All done!'
        @progress.legend = "Your changes have been submitted to #{prRepo} and
        are now pending review."
        @progress.buttons = [
            icon: 'fa-github'
            label: 'Open pull request'
            click: -> GitHub.openPullRequest pr
          ,
            icon: @package.type.icon
            label: "Upload another #{@package.type.casualName}"
            click: =>
              @reset()
              @progress = null
              window.scrollTo 0, 0
        ]
        @progress.done = true
        @dirty = false
      catch error
        @progress.error = error
  watch:
    '$route.params.type': -> @reset()
    package:
      deep: true
      handler: -> @dirty = true
    user: -> @updatePullRequests()
    fullscreen: (fs) ->
      document.body.classList.toggle 'noscroll', fs

      Vue.nextTick =>
        for editor in @$el.querySelectorAll '.CodeMirror'
          editor.CodeMirror.refresh()
  mounted: ->
    window.addEventListener 'beforeunload', @onBeforeUnload

    try
      @user = await GitHub.getUser()
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
@import 'upload-mixins'

.autocomplete
  position: relative

  .dropdown-menu
    width: 100%

button.main
  margin-right: 1em

.submit-legend
  color: $input-placeholder

.user
  float: right

  a
    font-weight: normal
    text-decoration: none
    color: inherit

  .avatar
    height: 1.3em
    vertical-align: middle
    border-radius: 3px

  button
    margin: 0
</style>
