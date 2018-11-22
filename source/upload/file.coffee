export default class File
  @UPLOAD: { icon: 'fa-upload', name: 'Upload' }
  @EXTERNAL: { icon: 'fa-link', name: 'External' }

  constructor: (@name, @isPackage = false) ->
    @source = @constructor.UPLOAD
    @url = ''
    @platform = ''
    @install = true
    @sections = []
    @type = ''
