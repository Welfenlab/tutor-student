ko = require 'knockout'
wavatar = require('../../util/gravatar').wavatar
app = require '../../app'
api = require '../../api'

class ViewModel
  constructor: ->
    @pseudonym = ko.observable app.user().pseudonym()
    @avatarUrl = ko.computed => wavatar @pseudonym()

  generate: ->
    api.get.pseudonym()
    .then (data) =>
      @pseudonym data.pseudonym
    .catch ->
      alert('Could not generate pseudonym')

  choose: ->
    api.put.pseudonym(@pseudonym())
    .then => app.user().pseudonym @pseudonym()
    .catch -> alert 'The pseudonym could not be selected. Please try again.'

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
