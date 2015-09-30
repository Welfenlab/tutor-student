ko = require 'knockout'
api = require '../../api'
ExerciseEditor = require '@tutor/exercise-editor'
markdown = require './markdown'

class ViewModel extends ExerciseEditor(ko).ExercisePageViewModel
  constructor: (params) ->
    super(params)

  show: (id) -> window.location.hash = '#exercise/' + id

  getExercise: (id, callback) ->
    api.get.group()
    .then (data) => @group = data
    .then -> api.get.exercise(id)
    .then(callback)
    .catch ->
      alert 'Loading the exercise failed.'

  init: (task) ->
    markdown task, @group

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
