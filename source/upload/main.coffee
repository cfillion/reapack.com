# document.body.addEventListener 'dragover', ->
#   app.drag = true
#
# document.body.addEventListener 'dragend', ->
#   app.drag = false
#
# document.body.addEventListener 'drop', (e) ->
#   e.preventDefault()

Vue        = require 'vue'
VueRouter  = require 'vue-router'

Main       = require './components/main.vue'
SelectType = require './components/select-type.vue'
Editor     = require './components/editor.vue'

router = new VueRouter
  # mode: 'history'
  base: '/upload'
  routes: [
    { path: '*', component: SelectType }
    # { path: '/auth', component: Auth }
    { path: '/:type', component: Editor }
  ]

Vue.use VueRouter

app = new Vue
  router: router,
  render: (createElement) -> createElement Main

app.$mount '#upload-main'
