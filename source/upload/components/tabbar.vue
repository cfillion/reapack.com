<template lang="slim">
.tabbar
  .tab-list
    button (
      type="button" v-for="(tab, i) in tabs" :class=="{ active: tab.isActive }"
      @click="setCurrentTab(tab)"
    ) {{ tab.name }}
  slot
</template>

<script lang="coffee">
export default
  data: -> { tabs: [] }
  created: -> @tabs = @$children
  mounted: -> @tabs[0]?.isActive = true
  methods:
    setCurrentTab: (newTab) ->
      tab.isActive = tab == newTab for tab in @tabs
</script>

<style lang="sass" scoped>
@import 'config'

.tabbar
  display: inline

.tab-list
  float: right
  font-size: 0.8rem

button
  display: inline
  padding: 3px 7px 2px 7px
  border: 1px solid $foreground
  border-left-style: none
  border-bottom-style: none
  border-radius: 0
  box-shadow: none
  margin: 0

  &:first-child
    border-top-left-radius: 4px
    border-left-style: solid
  &:last-child
    border-top-right-radius: 4px

  &.active
    background-color: $table-row-even
    font-weight: bold
</style>
