ko = require 'knockout'
app = require '../../app'
api = require '../../api'

class ViewModel
  constructor: ->
    @pin = ko.observable ''

    @mayLogin = ko.computed =>  @pin() isnt ''
    @isLoggingIn = ko.observable no

    @error = ko.observable null
    @hasError = ko.computed => @error() isnt null

  login: ->
    @isLoggingIn yes
    api.post.login @pin()
    .always =>
      @isLoggingIn no
    .done (data) =>
        app.user data
        app.router.goto 'overview'
    .fail (jqxhr) =>
        @error jqxhr.responseJSON.msg

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
