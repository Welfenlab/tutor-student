
exerciseEditor = require '@tutor/exercise-editor'
fs = require 'fs'

_ = require 'lodash'

moreMarkdown = require 'more-markdown'
mathjaxProcessor = require '@more-markdown/mathjax-processor'
codeControls     = require '@more-markdown/code-controls'
dotProcessor     = require '@more-markdown/dot-processor'
testProcessor    = require '@more-markdown/test-processor'

markdownEditor = require '@tutor/markdown-editor'
javascriptEditorErrors = require '@tutor/javascript-editor-errors'
testSuite      = require '@tutor/test-suite'
graphTestSuite = require '@tutor/graph-test-suite'
jsSandbox      = require '@tutor/javascript-sandbox'
jailedSandbox  = require '@tutor/jailed-sandbox'
browserDebug   = require '@tutor/browser-debug-js'

aceRethink     = require '@tutor/share-ace-rethinkdb/src/test.js'

createPreview = (id) ->
  moreMarkdown.create id,
    processors: [
      # The mathjax processor finds all LaTeX formulas and typesets them
      mathjaxProcessor,

      # The code controls add buttons to "js" code environments that allow
      # the user to run or debug the code
      codeControls("js",
          {
            run: jailedSandbox.run
            debug: _.partial jailedSandbox.debug, _, {}, timeout: 1*60*1000 # 1 minute
            # debug: browserDebug.debug # supports debugger but hangs on infinite loops
          }
          , _.template fs.readFileSync __dirname + "/js_controls.html", "utf8"),

      # The dot processor processes "dot" environments and creates SVG graphs
      # for these
      dotProcessor("dot", (_.template "<svg data-element-id=\"<%= id %>\"><g/></svg>"),
        _.template "<p style='background-color:red'><%= error %></p>")

      # The test processor creates the "test" code environment in which one can
      # define tests in yasmine syntax
      testProcessor(["test","tests"],
        {
          tests: [
            (testSuite.itTests 
              registerTest: ((name, elem)-> elem.innerHTML += "<li>#{name}</li>")
              testResult: ((status, index, elem)->
                  if status == null
                    elem.children[index].innerHTML += " <span style='color:green'>Success</span>";
                  else
                    elem.children[index].innerHTML += " <span style='color:red'>Failed (#{status.exception})</span>";
                )
              allResults: ((error, passed, failed) -> 
                console.log "passed #{passed}, failed #{failed} (error: #{error})")
              ),
            testSuite.jsTests,
            graphTestSuite.collectGraphs,
            graphTestSuite.graphApi,
            testSuite.debugLog
          ],
          runner: {
            run: _.partial jailedSandbox.run, _, _, timeout: 1*60*1000 # 1 minute
            debug: _.partial jailedSandbox.debug, _, _, timeout: 1*60*1000 # 1 minute
            # debug: browserDebug.debug # supports debugger but hangs on infinite loops
          }
          templates:{
            tests: _.template("<h1>Tests</h1><ul data-element-id=\"<%= id %>\"></ul>")
          }
        })
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


module.exports = (task) ->
  prev = createPreview "preview-" + task.id()
  markdownPreview = (editor) ->
    prev.render editor.getValue()

  shareDocConnection = (aceRethink markdownEditor.Range, "GRP", task.id(), {port:'8015'})

  if document.getElementById 'editor-' + task.id()
    editor = markdownEditor.create 'editor-' + task.id(), task.solution(), plugins: [
      markdownPreview,
      markdownEditor.clearResults,
      javascriptEditorErrors "js", prev
    ]

    shareDocConnection.connect(editor);

  prev.render task.solution()
