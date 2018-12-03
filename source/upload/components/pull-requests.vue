<template lang="slim" functional>
.pull-requests v-if="props.list.length > 0"
  p
    ' You have {{ props.list.length }}
    template> v-if="props.list.length == 1" pull request
    template> v-else="" pull requests
    | pending review on {{ props.repo }}:

  ul
    li v-for="pr in props.list"
      i.fa.fa-fw.fa-code-fork
      a :href="pr.html_url" target="_blank" {{ pr.title }}
      a.comments (
        v-if="pr.comments > 0" :href="pr.html_url" target="_blank"
        title="Comments"
      )
        i.fa.fa-fw.fa-comment-o
        | {{ pr.comments }}
</template>

<script lang="coffee">
export default
  props:
    list: Array
    repo: String
</script>

<style lang="sass">
@import 'upload-mixins'

.pull-requests
  +info-box($success)

  ul
    margin-left: 0
    list-style-type: none

.comments
  padding-left: $padding
  text-decoration: none
  font-weight: normal
</style>
