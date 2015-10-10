
exerciseEditor = require '@tutor/exercise-editor'
fs = require 'fs'
_ = require 'lodash'
EventEmitter = require 'event-emitter'

markdownEditor = require '@tutor/markdown-editor'
javascriptEditorErrors = require '@tutor/javascript-editor-errors'

aceRethink     = require '@tutor/share-ace-rethinkdb/src/test.js'

module.exports = (task, group, exercise, allTests, selectedIndex)  ->
  taskIdx = task.number() - 1

  createPreview = (require './markdown')({
    testProcessor:
      register: (name) ->
        tr = allTests()
        tr[taskIdx].push({name: name, passes: false})
        allTests(tr)
      testResult: (err, idx) ->
        tr = allTests()
        tr[taskIdx][idx].passes = (err == null)
        allTests tr
        selectedIndex taskIdx
      template: -> ""
    })

  prev = createPreview "preview-" + task.number()
  markdownPreview = (editor) ->
    tr = allTests()
    tr[taskIdx] = []
    allTests(tr)
    prev.render task.tests() + "\n\n" + editor.getValue()

  shareDocConnection = (aceRethink markdownEditor.Range, group.id, exercise.id+task.number(), {})

  returnedObject = {destroy: _.noop}
  EventEmitter.installOn returnedObject

  if document.getElementById 'editor-' + task.number()
    editor = markdownEditor.create 'editor-' + task.number(), task.prefilled(), plugins: [
      markdownPreview,
#      markdownEditor.clearResults,
#      javascriptEditorErrors "js", prev
    ]

    getStatus = shareDocConnection.connect(editor);

    previousStatus = {}
    checkStatus = ->
      previousStatus = status
      status = getStatus()

      if previousStatus
        if previousStatus.pending > 0 and status.pending == 0
          returnedObject.trigger 'save'
        else if previousStatus.pending == 0 and status.pending > 0
          returnedObject.trigger 'unsavedChanges'

        if previousStatus.state == 'connected' and status.state != 'connected'
          returnedObject.trigger 'disconnect'
        else if previousStatus.state != 'connected' and status.state == 'connected'
          returnedObject.trigger 'connect'
      else
        if status.state == 'connected'
          returnedObject.trigger 'connect'
        else
          returnedObject.trigger 'disconnect'
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
    returnedObject.destroy = ->
      returnedObject.off() #remove all event listeners
      clearInterval interval

  #prev.render task.prefilled()
  markdownPreview editor
  return returnedObject
