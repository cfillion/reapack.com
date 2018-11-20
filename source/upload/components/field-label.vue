<template lang="slim">
label :for="target"
  slot
  small< v-if="optional" (optional)
</template>

<script lang="coffee">
module.exports =
  props:
    target: String
    optional: Boolean
</script>

<style lang="sass" scoped>
label
  font-weight: bold

  small
    font-weight: normal
</style>
