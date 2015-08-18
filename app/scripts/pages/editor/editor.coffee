ko = require 'knockout'
api = require '../../api'
ExerciseEditor = require '@tutor/exercise-editor'

class ViewModel extends ExerciseEditor(ko).ExercisePageViewModel
  constructor: (params) ->
    super(params)

  show: (id) -> window.location.hash = '#exercise/' + id

  getExercise: (id, callback) ->
    api.get.exercise id, callback

  @getExercises
  
fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
