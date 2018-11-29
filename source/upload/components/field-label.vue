<template lang="slim" functional>
label :for="props.target"
  slot

  / using a tab to render a breakable whitespace *only* if the field is optional
  template v-if="props.optional"
    | &#32;
    small() (optional)
</template>

<script lang="coffee">
export default
  props:
    target: String
    optional: Boolean
</script>

<style lang="sass">
label
  font-weight: bold

  small
    font-weight: normal
</style>
