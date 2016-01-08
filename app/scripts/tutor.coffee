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

page '/', ->
  if app.isLoggedIn()
    app.goto (localStorage.getItem('post-login-redirect') || 'overview')
    localStorage.removeItem('post-login-redirect')
  else
    app.goto '/login'
page '/overview', overview
page '/login', login
page '/register', register
page '/exercise/:id', editor
page '/groups', group

$ ->
  page(hashbang: false, click: false, popstate: false) #handlers don't work, we do it on our own below
  $(document).on 'click', 'a', (e) ->
    if not /^https?:\/\//i.test($(this).attr('href'))
      e.preventDefault()
      e.stopImmediatePropagation()
      app.goto $(this).attr('href')

  $(window).on 'popstate', (e) ->
    if e.originalEvent.state
      app.goto e.originalEvent.state.path, e.originalEvent.state

$(document).ready ->
  $('.ui.dropdown').dropdown()
  $('.ui.accordion').accordion()
  ko.applyBindings app
