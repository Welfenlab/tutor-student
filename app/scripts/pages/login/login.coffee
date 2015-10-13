ko = require 'knockout'
Q = require 'q'
app = require '../../app'
api = require '../../api'

class ViewModel
  constructor: ->
    @pin = ko.observable 'ABC-DEF'

    @samlData = ko.observable({})
    @samlReady = ko.computed => @samlData().url?
    @isLoggingIn = ko.observable no

    @error = ko.observable null
    @hasError = ko.computed => @error() isnt null

    api.get.logindata()
    .then (data) => @samlData data

  loginDev: ->
    @isLoggingIn yes

    api.post.loginDev @pin()
    .then -> api.get.me()
    .then (data) =>
      @isLoggingIn no
      app.user ko.mapping.fromJS data
      app.router.goto 'overview'
    .catch (e) =>
      console.log e
      @error 'Login failed'
      @isLoggingIn no
      $('.login').transition('shake')

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
