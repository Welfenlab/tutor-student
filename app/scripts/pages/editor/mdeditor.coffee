
exerciseEditor = require '@tutor/exercise-editor'
fs = require 'fs'

_ = require 'lodash'

markdownEditor = require '@tutor/markdown-editor'
javascriptEditorErrors = require '@tutor/javascript-editor-errors'

aceRethink     = require '@tutor/share-ace-rethinkdb/src/test.js'

createPreview = require './markdown'

module.exports = (task, group, exercise )  ->
  prev = createPreview "preview-" + task.number()
  markdownPreview = (editor) ->
    prev.render editor.getValue()

  shareDocConnection = (aceRethink markdownEditor.Range, group.id, exercise.id+task.number(), {})

  if document.getElementById 'editor-' + task.number()
    editor = markdownEditor.create 'editor-' + task.number(), task.prefilled(), plugins: [
      markdownPreview,
      markdownEditor.clearResults,
      javascriptEditorErrors "js", prev
    ]

    getStatus = shareDocConnection.connect(editor);

    checkStatus = ->
      status = getStatus();
      if status.pending > 0 && status.state != "connected"
        editor.container.style.opacity=0.1
        #console.log "not connected and pending changes"
      else if status.pending > 0
        editor.container.style.opacity=0.6
        #console.log "pending changes"
      else if status.state != "connected"
        editor.container.style.opacity=0.3
        #console.log "not connected"
      else
        editor.container.style.opacity=1.0
        #console.log "connected"

    setInterval checkStatus, 5000

  prev.render task.prefilled()
