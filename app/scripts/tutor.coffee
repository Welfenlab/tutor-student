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

  app.route '/overview', component: overview
  app.route '/login', component: login, loginRequired: no
  app.route '/register', component: register
  app.route '/exercise/:id', component: editor
  app.route '/groups', component: group
  app.route '/', ->
    if app.isLoggedIn()
      if app.user().pseudonym().indexOf('Nameless Nobody') == 0
        app.goto '/register'
      else
        if localStorage.getItem('post-login-redirect') == '/'
          app.goto 'overview'
        else
          app.goto(localStorage.getItem('post-login-redirect') || 'overview', true)
        localStorage.removeItem('post-login-redirect')
    else
      app.goto '/login'

  ko.applyBindings app
