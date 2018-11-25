import indentString from 'indent-string'

Decorations =
  '.eel': '//'
  '.lua': '--'
  '.py': '#'
  '.reaperlangpack': '#'

export default class Header
  constructor: ->
    @fields = []

  push: (name, value = true) ->
    @fields.push [name, value]

  lines: (altStyle) ->
    for field in @fields
      [name, value] = field
      name = name.toUpperCase() if altStyle == 'ugly'
      line = if altStyle then "#{name}:" else "@#{name}"

      if Array.isArray value
        continue if value.length == 0
        value = value.join '\n'

      value = 'true' if altStyle && value == true

      unless value == true
        if value.includes '\n'
          line += "\n#{indentString value, 2}"
        else if altStyle == 'ugly'
          line += value # langpack formatting
        else
          line += " #{value}"

      line

  toString: (extension, altStyle) ->
    lines = @lines(altStyle).join '\n'
    return '' unless lines

    if decoration = Decorations[extension]
      # add spaces before non-empty lines
      lines = indentString lines, 1 unless altStyle == 'ugly'

      lines = indentString lines, 1,
        indent: decoration
        includeEmptyLines: true
    lines.concat '\n\n'

noIndex = new Header
noIndex.push 'noindex'

export NoIndexHeader = noIndex
