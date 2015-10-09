
fs = require 'fs'
_ = require 'lodash'

tutorMarkdown = require '@tutor/markdown2html'

config = 
  codeControls:
    template: _.template fs.readFileSync __dirname + "/js_controls.html", "utf8"
  dotProcessor:
    baseSVGTemplate: _.template "<svg data-element-id=\"<%= id %>\"><g/></svg>"
    errorTemplate: _.template "<p style='background-color:red'><%= error %></p>"
  testProcessor:
    template: _.template("<h1>Tests</h1><ul data-element-id=\"<%= id %>\"></ul>")

createPreview = tutorMarkdown config

module.exports = createPreview
