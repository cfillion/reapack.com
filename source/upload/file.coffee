class File
  constructor: (@name) ->
    @source = 'upload'
    @url = ''
    @platform = ''
    @sections = []

module.exports = File
