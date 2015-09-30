app = require './app'
ko = require 'knockout'

app.router.pages [
  {
    path: 'login'
    component: require('./pages/login/login')()
  }
  {
    path: 'register'
    component: require('./pages/register/register')()
  }
  {
    path: 'overview'
    component: require('./pages/exercises/exercises')()
  }
  {
    path: /exercise\/?(.*)/
    as: ['id'] #name the parameters
    component: require('./pages/editor/editor')()
  }
]

app.router.goto 'login'

$(window).bind "popstate", ->
  app.router.goto location.hash.substr(1)

$(document).ready ->
  $('.ui.dropdown').dropdown()
  $('.ui.accordion').accordion()
  ko.applyBindings app
