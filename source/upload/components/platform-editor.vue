<template lang="slim">
table
  tr
    th
    th
      | Linux
    th
      | macOS
    th
      | Windows
  tr
    th
      | 64-bit
    td
      input type="checkbox" checked=true
    td
      input type="checkbox" checked=true
    td
      input type="checkbox" checked=true
  tr
    th
      | 32-bit
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
</style>
