ko = require 'knockout'
wavatar = require('../../util/gravatar').wavatar
app = require '../../app'
api = require '../../api'

class ViewModel
  constructor: ->
    @pseudonym = ko.observable app.user().pseudonym()
    @avatarUrl = ko.computed => wavatar @pseudonym()
    @hasPseudonym = @pseudonym().indexOf('Nameless Nobody') != 0

    if !@hasPseudonym
      @generate()

  generate: ->
    api.get.pseudonym()
    .then (data) =>
      @pseudonym data.pseudonym
    .catch ->
      alert('Could not generate pseudonym')

  choose: ->
    api.put.pseudonym(@pseudonym())
    .then (data) =>
      app.user().group().users app.user().group().users().map (u) =>
        if u == app.user().pseudonym() then @pseudonym() else u
      app.user().pseudonym @pseudonym()
      app.goto 'overview'
    .catch (e) -> console.log e
    .catch -> alert 'The pseudonym could not be selected. Please try again.'

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
