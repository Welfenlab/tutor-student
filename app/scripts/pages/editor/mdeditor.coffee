
exerciseEditor = require '@tutor/exercise-editor'
fs = require 'fs'
_ = require 'lodash'
markdownProcessor = require('@tutor/task-preview').markdownProcessor
EventEmitter = require 'event-emitter'

markdownEditor = require '@tutor/markdown-editor'
javascriptEditorErrors = require '@tutor/javascript-editor-errors'

aceRethink     = require '@tutor/share-ace-rethinkdb/src/test.js'

module.exports = (task, group, exercise, allTests, selectedIndex)  ->
  taskIdx = task.number() - 1

  lastEdit = 0
  markdownPreview = (editor) ->
    lastEdit = lastEdit + 1
    curEdit = lastEdit
    curTests = allTests()
    curTests[taskIdx] = []
    task.solution editor.getValue()


  returnedObject = {destroy: _.noop}
  EventEmitter.installOn returnedObject

  if document.getElementById 'editor-' + task.number()
    editor = markdownEditor.create 'editor-' + task.number(), task.prefilled(), plugins: [
      _.throttle(markdownPreview,500),
      markdownEditor.clearResults,
      javascriptEditorErrors "js", markdownProcessor
    ]
    editor.on 'focus', -> selectedIndex taskIdx
    editor.on 'blur', -> selectedIndex(-1) if selectedIndex() == taskIdx

    shareDocConnection = aceRethink editor, markdownEditor.Range, group.id, exercise.id, task.number(), {document:"DummyUebung201516", prefill: task.prefilled()}

    shareDocConnection.on 'connect', =>
      returnedObject.trigger 'connect'

    shareDocConnection.on 'disconnect', =>
      returnedObject.trigger 'disconnect'

    previousStatus = {}
    checkStatus = ->
      previousStatus = status
      status = shareDocConnection.status()

      if previousStatus
        if previousStatus.pending > 0 and status.pending == 0
          returnedObject.trigger 'save'
        else if previousStatus.pending == 0 and status.pending > 0
          returnedObject.trigger 'unsavedChanges'
      else
        if status.pending == 0
          returnedObject.trigger 'save'
        else
          returnedObject.trigger 'unsavedChanges'

      #TODO Now that we have events, the GUI shouldn't be changed here...
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

    interval = setInterval checkStatus, 5000

    returnedObject.status = shareDocConnection.status #this is a function
    returnedObject.destroy = ->
      returnedObject.off() #remove all event listeners
      clearInterval interval
      #console.log shareDocConnection#'disconnect websocket'
      shareDocConnection.disconnect()
      shareDocConnection.off() #remove all event listeners

    returnedObject.ace = editor

  #prev.render task.prefilled()
  markdownPreview editor
  return returnedObject
