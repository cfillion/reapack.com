<template lang="slim">
.tabbar
  .tab-list
    button.tab-btn(
      v-for="(tab, i) in tabs" :class=="{ active: tab.isActive }"
      @click="setCurrentTab(tab)"
    ) {{ tab.name }}
  slot
</template>

<script lang="coffee">
module.exports =
  data: -> { tabs: [] }
  created: -> @tabs = @$children
  mounted: -> @tabs[0]?.isActive = true
  methods:
    setCurrentTab: (newTab) ->
      @tabs.forEach (tab) ->
        tab.isActive = tab == newTab
</script>

<style lang="sass">
@import 'config'

.tabbar
  display: inline

  .tab-list
    float: right
    font-size: 0.8rem

  .tab-btn
    display: inline
    padding: 3px 7px 2px 7px
    border: 1px solid $foreground
    border-left-style: none
    border-bottom-style: none
    border-radius: 0
    cursor: pointer
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
