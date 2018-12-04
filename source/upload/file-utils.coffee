import * as Types from './types'

makeCaseInsensitive = (pattern) ->
  pattern.replace /[a-z]/gi, (c) => "[#{c.toLowerCase()}#{c.toUpperCase()}]"

CON = makeCaseInsensitive 'CON'
PRN = makeCaseInsensitive 'PRN'
AUX = makeCaseInsensitive 'AUX'
NUL = makeCaseInsensitive 'NUL'
COM = makeCaseInsensitive 'COM'
LPT = makeCaseInsensitive 'LPT'

reservedChars = '*\\\\:<>?/|"\\x00-\\x1F\\x7F'

# Regex as an ugly string for use in the pattern input attribute.
# Using lookahead to combine the rules and so an additional pattern can be
# specified when used.
#
# See https://docs.microsoft.com/en-us/windows/desktop/fileio/naming-a-file#file-and-directory-names
export PathPattern =
  "(?=((^|/)[^#{reservedChars}]*)*$)" +
  "(?!((^|.*/)\\s*(#{CON}|#{PRN}|#{AUX}|#{NUL}|#{COM}\\d|#{LPT}\\d)\\s*(\\.[^/]*)?)*(/|$))" +
  '.*'

export validatePath = (filename) ->
  ///^#{PathPattern}$///.test filename

export sanitizeFilename = (filename, replacement = '') ->
  filename.replace ///[#{reservedChars}]///g, replacement

export makeExtensionPattern = (extensions) ->
  escapedExts = for ext in extensions
    makeCaseInsensitive ext.replace(/\./g, '\\.')

  "(#{escapedExts.join '|'})$"

export endsWithExtension = (filename, extensions) ->
  ///#{makeExtensionPattern extensions}///.test filename

export isIndexable = (matchExt) ->
  matchExt = matchExt.toLowerCase()

  for _, type of Types
    for ext in type.extensions
      return true if ext.toLowerCase() == matchExt

  false

export detectBinary = (content) ->
  content.includes '\0' # big assumption

export fileListToTree = (fileList) ->
  tree = []

  for file in fileList
    segments = file.split '/'

    next = tree

    for segment in segments[0..-2]
      leaf = next.find (l) => l.name == segment

      if leaf
        next = leaf.tree
        continue

      leaf = { name: segment, tree: [] }
      next.push leaf
      next = leaf.tree

    next.push name: segments[segments.length - 1], tree: []

  tree
