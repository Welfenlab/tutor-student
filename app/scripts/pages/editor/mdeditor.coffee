
exerciseEditor = require '@tutor/exercise-editor'
fs = require 'fs'
_ = require 'lodash'
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
    createPreview = (require './markdown')({
      testProcessor:
        register: (name) ->
          if lastEdit > curEdit
            return
          curTests[taskIdx].push({name: name, passes: false})
        testResult: (err, idx) ->
          if lastEdit > curEdit
            return
          curTests[taskIdx][idx].passes = (err == null)
        testsFinished: ->
          if lastEdit > curEdit
            return
          allTests(curTests)
        template: -> ""
      })

    prev = createPreview "preview-" + task.number()
    prev.render task.tests() + "\n\n" + editor.getValue()


  returnedObject = {destroy: _.noop}
  EventEmitter.installOn returnedObject

  if document.getElementById 'editor-' + task.number()
    editor = markdownEditor.create 'editor-' + task.number(), task.prefilled(), plugins: [
      _.throttle(markdownPreview,500),
#      markdownEditor.clearResults,
#      javascriptEditorErrors "js", prev
    ]
    editor.on 'focus', -> selectedIndex taskIdx
    editor.on 'blur', -> selectedIndex(-1) if selectedIndex() == taskIdx

    shareDocConnection = aceRethink editor, markdownEditor.Range, group.id, exercise.id, task.number(), {document:"DummyUebung201516"}

    previousStatus = {}
    checkStatus = ->
      previousStatus = status
      status = shareDocConnection.status()
      #TODO use the events of shareDocConnection

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
      console.log shareDocConnection#'disconnect websocket'
      shareDocConnection.disconnect()

  #prev.render task.prefilled()
  markdownPreview editor
  return returnedObject
