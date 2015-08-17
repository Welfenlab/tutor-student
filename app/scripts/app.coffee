ko = require 'knockout'
require 'knockout-mapping'
api = require './api'
#overview = './pages/overview'
#editor = './pages/exercise_editor'
#not_found = './pages/not_found'
fs = require 'fs'
login = require '@tutor/login-form'
exerciseList = require '@tutor/exercise-list'
editor = require './editor'


ko.components.register 'login-form', login ko,
  html: (fs.readFileSync __dirname + '/pages/login.html').toString()
  username: 'c7b628a1-1df5-4c23-bf11-fc28872de3b0'
  redirect: '/#overview'
  validate: (pin, password) -> pin isnt '' and password isnt ''
  authorize: api.post.login

ko.components.register 'exercise-list', exerciseList ko,
  html: (fs.readFileSync __dirname + '/pages/exerciseList.html').toString()
  show: (id) -> window.location.hash = '#exercise/' + id
  getExercises: api.get.exercises
ko.components.register 'page-exercise-editor', editor ko
ko.components.register 'page-not-found', template: "<h2>Page not found</h2>"

viewModel =
  user: ko.observable({
    loggedIn: yes
    name: 'Jon Doe'
    avatar: 'http://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50?f=y&d=monsterid'
  })

  selected: ko.observable()
  parameters: ko.observable {}
  path: ko.observable()
  pages: [
    {
      path: 'login'
      component: 'login-form'
    },
    {
      path: 'overview'
      component: 'exercise-list'
    },
    {
      path: /exercise\/?(.*)/
      as: ['id'] #name the parameters
      component: 'page-exercise-editor'
    }
  ]

rename = (array, names) ->
  obj = {}
  for item, i in array
    obj[names[i]] = item
  return obj

viewModel.path.subscribe (v) ->
  if v is ''
    v = 'login'

  found = no
  result = null
  for page in viewModel.pages
    if page.path is v or (result = v.match page.path) isnt null
      if result?
        viewModel.parameters rename result.slice(1), page.as
      else
        viewModel.parameters {}
      viewModel.selected page.component
      found = yes
      break

  if not found
    viewModel.selected 'page-not-found'

$(window).bind "popstate", ->
  path = location.hash.substr(1);
  viewModel.path path

$(window).trigger "popstate" #trigger load of start page

$(document).ready ->
  $('.ui.dropdown').dropdown()
  $('.ui.accordion').accordion()
  ko.applyBindings viewModel
