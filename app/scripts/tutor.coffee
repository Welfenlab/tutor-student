app = require './app'
ko = require 'knockout'

overview = require('./pages/exercises/exercises')()
login = require('./pages/login/login')()
register = require('./pages/register/register')()
editor = require('./pages/editor/editor')()
group = require('./pages/group/group')()

$ ->
  $('.ui.dropdown').dropdown()
  $('.ui.accordion').accordion()

  app.register '/overview', component: overview
  app.register '/login', component: login, loginRequired: no
  app.register '/register', component: register
  app.register '/exercise/:id', component: editor
  app.register '/groups', component: group
  app.register '/', ->
    if app.isLoggedIn()
      if app.user().pseudonym().indexOf('Nameless Nobody') == 0
        app.goto '/register'
      else
        app.goto(localStorage.getItem('post-login-redirect') || 'overview', true)
        localStorage.removeItem('post-login-redirect')
    else
      app.goto '/login'

  ko.applyBindings app
