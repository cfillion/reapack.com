<template lang="slim" functional>
label :for="props.target"
  slot
  small< v-if="props.optional" (optional)
</template>

<script lang="coffee">
export default
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
