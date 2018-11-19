# document.body.addEventListener 'dragover', ->
#   app.drag = true
#
# document.body.addEventListener 'dragend', ->
#   app.drag = false
#
# document.body.addEventListener 'drop', (e) ->
#   e.preventDefault()

Types =
  reascript:
    name: 'ReaScript'
    repo: 'ReaTeam/ReaScripts'
    desc: 'Upload a Lua, EEL or Python script to the ReaTeam/ReaScripts repository.'
    icon: 'fa-file-text'

    placeholders:
      name: 'Float instrument relevant to MIDI editor',
      changelog: 'Create an undo point when inserting tracks in the project\nAllow square braquets to be typed in the input box'

  jsfx:
    name: 'JS effect'
    repo: 'ReaTeam/JSFX'
    desc: 'Upload a JS effect to the ReaTeam/JSFX repository.'
    icon: 'fa-cogs'

    placeholders:
      name: 'Bass professor MK2'
      changelog: 'Increase band handle size\nImprove CPU usage by 90%'

  theme:
    name: 'Theme'
    repo: 'ReaTeam/Themes'
    desc: 'Upload a theme package on the ReaTeam/Themes repository.'
    icon: 'fa-paint-brush'

    placeholders:
      name: 'Default v5 Dark Theme'
      changelog: 'Added support for embedded effects in the TCP\nReplaced mcp_master_vol.png'

  langpack:
    name: 'Language pack'
    repo: 'ReaTeam/LangPacks'
    desc: 'Upload a ReaperLangPack file to the ReaTeam/LangPacks repository.'
    icon: 'fa-globe'

    placeholders:
      name: 'Traduction française (REAPER + SWS)'
      changelog: 'Added new strings in the Preferences window\nImprove consistency of the item editing action names'

  extension:
    name: 'Extension'
    repo: 'ReaTeam/Extensions'
    desc: 'Upload an extension plugin to the ReaTeam/Extensions repository.'
    icon: 'fa-puzzle-piece'

    placeholders:
      name: 'OpenGL API functions for ReaScripts'
      changelog: 'Fix crash on Linux and macOS when exporting regions containing slashes\nExpose a few PCM_source capabilities to ReaScripts'

SelectType =
  template: '#select-type'
  data: -> { types: Types }

Auth =
  template: '#auth'

Editor =
  template: '#editor'
  data: ->
    category: ''
    name: ''
    author: ''
    about: ''
    aboutPreview: ''
  computed:
    type: -> Types[@$route.params.type]
    repoUrl: -> "https://github.com/#{@type.repo}"
    indexUrl: -> "#{@repoUrl}/raw/master/index.xml"
    aboutPlaceholder: ->
      name = @name.trim()
      name = 'Package name' unless name
      "# #{name}\n\nLonger description of the package name here.\n\n
      Key features:\n\n- Lorem ipsum\n- Dolor sit amet\n- Consectetur adipiscing elit"
  methods:
    refreshPreview: ->
      reader = new commonmark.Parser
      writer = new commonmark.HtmlRenderer safe: true
      parsed = reader.parse if @about then @about else @aboutPlaceholder
      walker = parsed.walker()

      # disable images
      while event = walker.next()
        node = event.node

        if event.entering && node.type == 'image'
          node._type = 'link'

      @aboutPreview = writer.render parsed
  # beforeRouteLeave: (to, from, next) ->
  #   if window.confirm 'Do you really want to leave? Data you have entered will be lost.'
  #     next()
  #   else
  #     next(false)

Vue.component 'tabbar',
  data: -> { tabs: [] }
  created: -> @tabs = @$children
  mounted: -> @tabs[0]?.isActive = true
  methods:
    setCurrentTab: (newTab) ->
      @tabs.forEach (tab) ->
        tab.isActive = tab == newTab

  template: '#tabbar',

Vue.component 'tab',
  data: -> { isActive: false }
  template: '#tab'
  props: ['name']
  watch:
    isActive: -> @$emit 'activated' if @isActive

Vue.component 'link-editor',
  data: -> { links: [], type: 'screenshot', name: '', url: '' }
  computed:
    namePlaceholder: ->
      switch @type
        when 'link'
          'ReaPack website'
        when 'screenshot'
          'Docked mode'
        when 'donation'
          'Donate to cfillion'
    urlPlaceholder: ->
      switch @type
        when 'link'
          'https://reapack.com'
        when 'screenshot'
          'https://i.imgur.com/4xPMV9J.gif'
        when 'donation'
          'https://paypal.me/cfillion'
  template: '#link-editor'
  methods:
    removeLink: (i) -> @links.splice(i, 1)
    submit: ->
      name = @name.trim()
      url = @url.trim()

      icon = switch @type
        when 'link'
          'fa-link'
        when 'screenshot'
          'fa-picture-o'
        when 'donation'
          'fa-paypal'

      return unless icon && url

      @links.push {type: @type, icon: icon, name: name, url: url}
      @name = @url = ''

router = new VueRouter
  # mode: 'history'
  base: '/upload'
  routes: [
    { path: '*', component: SelectType }
    { path: '/auth', component: Auth }
    { path: '/:type', component: Editor }
  ]

new Vue({router}).$mount '#upload'
