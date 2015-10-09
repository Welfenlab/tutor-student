
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

    shareDocConnection.connect(editor);

  prev.render task.prefilled()
