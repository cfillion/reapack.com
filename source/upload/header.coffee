import indentString from 'indent-string'

Decorations =
  '.lua': '--'
  '.eel': '//'
  '.py':  '#'

export default class Header
  constructor: ->
    @fields = []

  push: (name, value = true) ->
    @fields.push [name, value]

  lines: ->
    for field in @fields
      [name, value] = field
      line = "@#{name}"

      if Array.isArray value
        continue if value.length == 0
        value = value.join '\n'

      unless value == true
        if value.includes '\n'
          line += "\n#{indentString value, 2}"
        else
          line += " #{value}"

      line

  toString: (extension) ->
    lines = @lines().join '\n'
    return '' unless lines

    if decoration = Decorations[extension]
      lines = indentString lines, 1 # add spaces before non-empty lines
      lines = indentString lines, 1,
        indent: decoration
        includeEmptyLines: true
    lines.concat '\n\n'

noIndex = new Header
noIndex.push 'noindex'

export NoIndexHeader = noIndex
