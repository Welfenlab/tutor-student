app = require './app'
ko = require 'knockout'
page = require 'page'

showPage = (component, loginRequired, ctx) ->
  app.path ctx.path
  app.pageParams ctx.params
  app.pageRequiresLogin loginRequired
  app.page component

overview = showPage.bind(null, require('./pages/exercises/exercises')(), yes)
login = showPage.bind(null, require('./pages/login/login')(), no)
register = showPage.bind(null, require('./pages/register/register')(), yes)
editor = showPage.bind(null, require('./pages/editor/editor')(), yes)
group = showPage.bind(null, require('./pages/group/group')(), yes)

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

  page '/overview', overview
  page '/login', login
  page '/register', register
  page '/exercise/:id', editor
  page '/groups', group
  page '/', ->
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
