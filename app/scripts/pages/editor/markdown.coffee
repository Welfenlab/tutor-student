
fs = require 'fs'
_ = require 'lodash'

tutorMarkdown = require '@tutor/markdown2html'

defaultConfig = 
  codeControls:
    template: _.template fs.readFileSync __dirname + "/js_controls.html", "utf8"
  dotProcessor:
    baseSVGTemplate: _.template "<svg data-element-id=\"<%= id %>\"><g/></svg>"
    errorTemplate: _.template "<p style='background-color:red'><%= error %></p>"
  testProcessor:
    register: ->
    testResult:  ->
    testsFinished: ->
    template: _.template("<h1>Tests</h1><ul data-element-id=\"<%= id %>\"></ul>")

module.exports = (config) ->
  config = config or {}
  localConf = _.defaultsDeep {}, config, defaultConfig
  
  tutorMarkdown localConf
