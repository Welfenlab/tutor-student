
api = require './api'
exerciseEditor = require '@tutor/exercise-editor'
fs = require 'fs'

_ = require 'lodash'

moreMarkdown = require 'more-markdown'
mathjaxProcessor = require '@more-markdown/mathjax-processor'
codeControls     = require '@more-markdown/code-controls'

markdownEditor = require '@tutor/markdown-editor'
javascriptEditorErrors = require '@tutor/javascript-editor-errors'
dbg = require '@tutor/browser-debug-js'

createPreview = (id) ->
  moreMarkdown.create id,
    processors: [
      mathjaxProcessor,
      codeControls("js",{
        run: eval,
        debug: dbg.debug
      }, _.template (fs.readFileSync __dirname + '/pages/js_controls.html').toString())
    ]
    html: false #disable inline HTML
    highlight: (code, lang) ->
      try
        if lang? and hljs.getLanguage lang
          return hljs.highlight(lang, code).value
        else
          return hljs.highlightAuto(code).value
      catch
        return ''

module.exports = (ko) ->
  exerciseEditor ko,
    html: (fs.readFileSync __dirname + '/pages/editor.html').toString()
    getExercise: api.get.exercise
    saveExercise: api.put.exercise
    taskInitialized: (task) ->
      prev = createPreview "preview-" + task.id()
      markdownPreview = (editor) ->
        prev.render editor.getValue()

      if document.getElementById 'editor-' + task.id()
        editor = markdownEditor.create 'editor-' + task.id(), task.solution(), plugins: [
          markdownPreview,
          markdownEditor.clearResults,
          javascriptEditorErrors prev
        ]

      prev.render task.solution()
