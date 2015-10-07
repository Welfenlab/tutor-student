ko = require 'knockout'
app = require '../../app'
api = require '../../api'

class ViewModel
  constructor: ->
    @pseudonym = ko.observable ''
    @generate()

  generate: ->
    api.get.pseudonym()
    .then (data) =>
      @pseudonym data.pseudonym
    .catch ->
      alert('Could not generate pseudonym')
  
  choose: ->
    api.put.pseudonym(@pseudonym)
    .then ->
      

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
