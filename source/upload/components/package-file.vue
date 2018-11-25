<template lang="slim">
div
  p
    field-label target="source" File source
    input-dropdown#source (
      :value="file.source" @input="file.setSource($event)"
      :choices="availableSources" :disabled="file.isPackage"
    )

  template v-if="file.source == $options.UploadSource"
    p
      field-label Storage directory
      | /{{ file.storageDirectory() }}/

    p v-if="file.source == $options.UploadSource"
      field-label target="storage-name" Storage file name
      input#storage-name (
        type="text" v-model.trim="file.storageName"
        :placeholder="file.effectiveStorageName()"
      )

  p v-else-if="file.source == $options.ExternalSource"
    field-label target="download-url" Download URL
    input#download-url type="url" v-model.trim="file.url"
    | Available variables:
      <code title="The path of the file relative to the repository">$path</code>,
      <code title="The hash of the commit being indexed or &quot;master&quot; if unavailable">$commit</code>,
      <code title="The version of the package being indexed">$version</code> and
      <code title="The package being indexed (path relative to the repository)">$package</code>.

  p
    field-label target="file-type" Resource type
    input-dropdown#file-type (
      v-model="type" :choices="availableTypes" :disabled="!file.canInstall()"
    )

  template v-if="file.install"
    p
      field-label target="target-name" optional=true Install location
      input#target-name (
        type="text" v-model.trim="file.installName"
        :placeholder="file.effectiveInstallName()"
      )
      | &lt;resource path&gt;/{{ file.installPath() }}

    p v-if="file.effectiveType().actionList"
      field-label target="sections" optional=true Action List
      input-dropdown#sections(v-model="file.sections" multiple=true
        :choices="$options.ScriptSections")

    p
      field-label target="platforms" Target platform
      input-dropdown#platforms :value="platformName"
        platform-matrix v-model="file.platform" @display="platformName = $event"

  p v-if="file.source == $options.UploadSource" ref="editor"
    field-label Contents
    package-file-content (
      v-model="file.content" :header="file.header()"
        :filename="file.effectiveInstallName()"
    )
</template>

<script lang="coffee">
import File, { UploadSource, ExternalSource, ScriptSections } from '../file'
import * as Types from '../types'

import FieldLabel from './field-label.vue'
import InputDropdown from './input-dropdown.vue'
import PackageFileContent from './package-file-content.vue'
import PlatformMatrix from './platform-matrix.vue'

DisabledType = { icon: 'fa-ban', name: "Don't install" }

export default
  UploadSource: UploadSource, ExternalSource: ExternalSource,
  ScriptSections: ScriptSections,
  components: { FieldLabel, InputDropdown, PackageFileContent, PlatformMatrix }
  props:
    file:
      type: Object
      required: true
  data: ->
    platformName: ''
  computed:
    sameAsPackageType: ->
      sameAsPackage: true
      icon: @file.package.type.icon
      name: "#{@file.package.type.name} (same as package)"
    availableSources: ->
      sources = [
        UploadSource,
        ExternalSource,
      ]
      sources
    type:
      get: ->
        if @file.install
          @file.type || @sameAsPackageType
        else
          DisabledType
      set: (type) ->
        if type == DisabledType
          @file.install = false
        else
          @file.type = if type.sameAsPackage then null else type
          @file.install = true
    availableTypes: ->
      types = []
      types.push @sameAsPackageType
      types.push DisabledType if @file.source == UploadSource
      return types if @file.isPackage

      types.push { separator: true }
      types.push Types[key] for key in Object.keys(Types).sort()
      types
</script>

<style lang="sass">
code[title]
  cursor: help
  text-decoration: underline dotted
</style>
