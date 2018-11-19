<template lang="slim">
span
  label :for="target": slot
  small< v-if="optional" (optional)
</template>

<script lang="coffee">
module.exports =
  props:
    target: String
    optional: Boolean
</script>
