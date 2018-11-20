<template lang="slim">
table
  thead
    tr
      th
      th
        | Linux
      th
        | macOS
      th
        | Windows
  tbody
    tr
      th
        | 32-bit
      td
        input type="checkbox" checked=true
      td
        input type="checkbox" checked=true
      td
        input type="checkbox" checked=true
    tr
      th
        | 64-bit
      td
        input type="checkbox" checked=true
      td
        input type="checkbox" checked=true
      td
        input type="checkbox" checked=true
</template>

<style lang="sass" scoped>
td
  text-align: center

tbody tr:last-child
  border-bottom: none
</style>
