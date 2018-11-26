import indentString from 'indent-string'

Styles =
  '.lua': { decoration: '--' }
  '.eel': { decoration: '//' }
  '.py':  { decoration: '#' }
  '.jsfx':
    altSyntax: true
    replace:
      description: 'desc'
  '.reaperlangpack':
    decoration: '#',
    altSyntax: true,
    compressed: true,
    uppercase: true
    replace:
      description: 'name'

export default class Header
  constructor: ->
    @fields = []

  push: (name, value = true) ->
    @fields.push [name, value]

  lines: (style) ->
    for field in @fields
      [name, value] = field
      name = replacement if style.replace && (replacement = style.replace[name])
      name = name.toUpperCase() if style.uppercase

      line = if style.altSyntax then "#{name}:" else "@#{name}"

      if Array.isArray value
        continue if value.length == 0
        value = value.join '\n'

      value = 'true' if style.altSyntax && value == true

      unless value == true
        if value.includes '\n'
          line += "\n#{indentString value, 2}"
        else if style.compressed
          line += value # langpack formatting
        else
          line += " #{value}"

      line

  toString: (extension, type) ->
    style = Styles[extension] ? Styles[type.extensions[0].toLowerCase()] ? {}

    lines = @lines(style).join '\n'
    return '' unless lines

    if style.decoration
      # add spaces before non-empty lines
      lines = indentString lines, 1 unless style.compressed

      lines = indentString lines, 1,
        indent: style.decoration
        includeEmptyLines: true

    lines.concat '\n\n'

noIndex = new Header
noIndex.push 'noindex'

export NoIndexHeader = noIndex
