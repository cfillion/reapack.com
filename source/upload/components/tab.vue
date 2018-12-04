<template lang="slim">
.tab.group v-show="isActive"
  slot
</template>

<script lang="coffee">
export default
  data: -> { isActive: false }
  props: ['name']
  watch:
    isActive: -> @$emit 'activated' if @isActive
</script>

<style lang="sass">
.tab
  clear: both
  border-top-right-radius: 0
</style>
