app = require './app'
ko = require 'knockout'
page = require 'page'

showPage = (component, ctx) ->
  app.path ctx.path
  app.pageParams ctx.params
  app.page component

overview = showPage.bind(null, require('./pages/exercises/exercises')())
login = showPage.bind(null, require('./pages/login/login')())
register = showPage.bind(null, require('./pages/register/register')())
editor = showPage.bind(null, require('./pages/editor/editor')())
group = showPage.bind(null, require('./pages/group/group')())

page '/', '/overview'
page '/overview', overview
page '/login', login
page '/register', register
page '/exercise/:id', editor
page '/group', group

page(hashbang: true)

$(document).ready ->
  $('.ui.dropdown').dropdown()
  $('.ui.accordion').accordion()
  ko.applyBindings app
