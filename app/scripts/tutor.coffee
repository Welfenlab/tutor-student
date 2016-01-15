app = require './app'
ko = require 'knockout'
page = require 'page'

overview = require('./pages/exercises/exercises')()
login = require('./pages/login/login')()
register = require('./pages/register/register')()
editor = require('./pages/editor/editor')()
group = require('./pages/group/group')()

$ ->
  $(document).on 'click', 'a', (e) ->
    if $(this).attr('href') and not /^https?:\/\//i.test($(this).attr('href'))
      e.preventDefault()
      app.goto($(this).attr('href'))
      return false

  #$(window).on 'popstate', (e) ->
    #if e.originalEvent.state
    #  app.goto e.originalEvent.state.path, e.originalEvent.state

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
        app.goto(localStorage.getItem('post-login-redirect') || 'overview')
        localStorage.removeItem('post-login-redirect')
    else
      app.goto '/login'

  page(hashbang: false, click: false, popstate: true) #handlers don't work, we do it on our own below

  app.onload()

  ko.applyBindings app
