export reascript =
  type: 'script'
  name: 'ReaScript'
  repo: 'ReaTeam/ReaScripts'
  desc: 'Upload a Lua, EEL or Python script to the ReaTeam/ReaScripts repository.'
  icon: 'fa-file-code-o'

  actionList: true
  extensions: ['.lua', '.eel', '.py']
  installRoot: 'Scripts/ReaTeam Scripts'
  longPath: true

  placeholders:
    name: 'Float instrument relevant to MIDI editor'
    changelog: 'Create an undo point when inserting tracks in the project\nAllow square braquets to be typed in the input box'

export jsfx =
  type: 'effect'
  name: 'JS effect'
  repo: 'ReaTeam/JSFX'
  desc: 'Upload a JS effect to the ReaTeam/JSFX repository.'
  icon: 'fa-cogs'

  extensions: ['.jsfx']
  installRoot: 'Effects/ReaTeam Scripts'
  longPath: true

  placeholders:
    name: 'Bass professor MK2'
    changelog: 'Increase band handle size\nImprove CPU usage by 90%'

export theme =
  type: 'theme'
  name: 'Theme'
  repo: 'ReaTeam/Themes'
  desc: 'Upload a theme package on the ReaTeam/Themes repository.'
  icon: 'fa-paint-brush'

  extensions: ['.theme']
  installRoot: 'ColorThemes'
  metapackage: true

  placeholders:
    name: 'Default v5 Dark Theme'
    changelog: 'Added support for embedded effects in the TCP\nReplaced mcp_master_vol.png'

export langpack =
  type: 'langpack'
  name: 'Language pack'
  repo: 'ReaTeam/LangPacks'
  desc: 'Upload a ReaperLangPack file to the ReaTeam/LangPacks repository.'
  icon: 'fa-globe'

  extensions: ['.ReaperLangPack']
  installRoot: 'LangPack'
  noAuthorSlug: true

  placeholders:
    name: 'Traduction française (REAPER + SWS)'
    changelog: 'Added new strings in the Preferences window\nImprove consistency of the item editing action names'

export extension =
  type: 'extension'
  name: 'Extension'
  repo: 'ReaTeam/Extensions'
  desc: 'Upload an extension plugin to the ReaTeam/Extensions repository.'
  icon: 'fa-puzzle-piece'

  extensions: ['.ext']
  installRoot: 'UserPlugins'
  metapackage: true

  placeholders:
    name: 'OpenGL API functions for ReaScripts'
    changelog: 'Fix crash on Linux and macOS when exporting regions containing slashes\nExpose a few PCM_source capabilities to ReaScripts'

export automationItem =
  type: 'autoitem'
  name: 'Automation item'
  icon: 'fa-area-chart'

  extensions: ['.ReaperAutoItem']
  installRoot: 'AutomationItems'
  longPath: true

export midiNoteNames =
  type: 'midinotenames'
  name: 'MIDI Note Names'
  icon: 'fa-file-text-o'

  extensions: ['.txt']
  installRoot: 'MIDINoteNames'

export projectTemplate =
  type: 'projecttpl'
  name: 'Project template'
  icon: 'fa-cube'

  extensions: ['.RPP']
  installRoot: 'ProjectTemplates'

export trackTemplate =
  type: 'tracktpl'
  name: 'Track template'
  icon: 'fa-sliders'

  extensions: ['.RTrackTemplate']
  installRoot: 'TrackTemplates'

export webInterface =
  type: 'webinterface'
  name: 'Web interface'
  icon: 'fa-mouse-pointer'

  extensions: ['.www']
  installRoot: 'reaper_www_root'

export data =
  type: 'data'
  name: 'Data'
  icon: 'fa-file-o'

  extensions: ['.data']
  installRoot: 'Data'
  metapackage: true
