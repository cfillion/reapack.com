export reascript =
  name: 'ReaScript'
  repo: 'ReaTeam/ReaScripts'
  desc: 'Upload a Lua, EEL or Python script to the ReaTeam/ReaScripts repository.'
  icon: 'fa-file-code-o'

  actionList: true

  placeholders:
    name: 'Float instrument relevant to MIDI editor'
    changelog: 'Create an undo point when inserting tracks in the project\nAllow square braquets to be typed in the input box'

export jsfx =
  name: 'JS effect'
  repo: 'ReaTeam/JSFX'
  desc: 'Upload a JS effect to the ReaTeam/JSFX repository.'
  icon: 'fa-cogs'

  placeholders:
    name: 'Bass professor MK2'
    changelog: 'Increase band handle size\nImprove CPU usage by 90%'

export theme =
  name: 'Theme'
  repo: 'ReaTeam/Themes'
  desc: 'Upload a theme package on the ReaTeam/Themes repository.'
  icon: 'fa-paint-brush'

  placeholders:
    name: 'Default v5 Dark Theme'
    changelog: 'Added support for embedded effects in the TCP\nReplaced mcp_master_vol.png'

export langpack =
  name: 'Language pack'
  repo: 'ReaTeam/LangPacks'
  desc: 'Upload a ReaperLangPack file to the ReaTeam/LangPacks repository.'
  icon: 'fa-globe'

  placeholders:
    name: 'Traduction française (REAPER + SWS)'
    changelog: 'Added new strings in the Preferences window\nImprove consistency of the item editing action names'

export extension =
  name: 'Extension'
  repo: 'ReaTeam/Extensions'
  desc: 'Upload an extension plugin to the ReaTeam/Extensions repository.'
  icon: 'fa-puzzle-piece'

  placeholders:
    name: 'OpenGL API functions for ReaScripts'
    changelog: 'Fix crash on Linux and macOS when exporting regions containing slashes\nExpose a few PCM_source capabilities to ReaScripts'

export automationItem =
  name: 'Automation item'
  icon: 'fa-area-chart'

export midiNoteNames =
  name: 'MIDI Note Names'
  icon: 'fa-file-text-o'

export projectTemplate =
  name: 'Project template'
  icon: 'fa-cube'

export trackTemplate =
  name: 'Track template'
  icon: 'fa-sliders'

export webInterface =
  name: 'Web interface'
  icon: 'fa-mouse-pointer'
