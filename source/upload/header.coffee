import indentString from 'indent-string'

Decorations =
  '.lua': '-- '
  '.eel': '// '
  '.py':  '# '

export default class Header
  constructor: ->
    @fields = []

  push: (name, value = true) ->
    @fields.push [name, value]

  lines: ->
    for field in @fields
      [name, value] = field

      line = "@#{name}"
      value = value.join '\n' if Array.isArray value

      if value != true && value.length > 0
        if value.includes '\n'
          line += "\n#{indentString value, 2}"
        else
          line += " #{value}"

      line

  toString: (extension) ->
    lines = @lines().join '\n'
    if decoration = Decorations[extension]
      lines = indentString lines, 1,
        indent: decoration
        includeEmptyLines: true
    lines

noIndex = new Header
noIndex.push 'noindex'

export NoIndexHeader = noIndex
