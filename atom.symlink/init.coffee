path = require 'path'

atom.workspace.observeTextEditors (editor) ->
  if path.extname(editor.getPath()) is '.md'
    editor.setSoftWrap(true)

atom.commands.add 'atom-workspace', 'core:cancel', ->
  atom.notifications.getNotifications().forEach (notification) ->
    notification.dismiss()
