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

page '/', '/overview'
page '/overview', overview
page '/login', login
page '/register', register
page '/exercise/:id', editor
page '/groups', group

$ ->
  page(hashbang: true, click: false, popstate: false) #handlers don't work, we do it on our own below
  $(document).on 'click', 'a', (e) ->
    el = e.target
    if el.tagName == 'A'
      if not /^https?:\/\//i.test(el.getAttribute('href'))
        e.preventDefault()
        e.stopImmediatePropagation()
        app.goto el.getAttribute('href')

  $(window).on 'popstate', (e) ->
    if e.originalEvent.state
      app.goto e.originalEvent.state.path, e.originalEvent.state

$(document).ready ->
  $('.ui.dropdown').dropdown()
  $('.ui.accordion').accordion()
  ko.applyBindings app
