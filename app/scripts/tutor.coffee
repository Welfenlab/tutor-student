app = require './app'
ko = require 'knockout'
page = require 'page'

showPage = (component, loginRequired, ctx) ->
  app.path ctx.path
  app.pageParams ctx.params
  app.page component
  app.pageRequiresLogin loginRequired

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
page(hashbang: true)

# Fix to make links to pages work:
window.addEventListener 'hashchange', -> app.goto window.location.hash.substr(3)

$(document).ready ->
  $('.ui.dropdown').dropdown()
  $('.ui.accordion').accordion()
  ko.applyBindings app
