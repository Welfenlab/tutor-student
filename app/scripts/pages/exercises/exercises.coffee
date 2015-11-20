ko = require 'knockout'
api = require '../../api'
ExerciseList = require('@tutor/exercise-list')(ko)

class ExerciseViewModel extends ExerciseList.ExerciseViewModel
  constructor: (data) ->
    super(data)

  show: -> window.location.hash = '#exercise/' + @id

class ViewModel extends ExerciseList.OverviewPageViewModel
  constructor: ->
    super()
    @timeDifference = ko.observable 0
    @localTime = ko.observable Date.now()
    @serverTime = ko.computed => @localTime() + @timeDifference()

    @exercisesActive = ko.computed =>
      @exercises().filter  (ex) =>
        Date.parse(ex.dueDate()) < @serverTime()

    @exercisesPrevious = ko.computed =>
      @exercises().filter  (ex) =>
        Date.parse(ex.dueDate()) > @serverTime()
      
  getExercises: (callback) ->
    api.get.exercises()
    .then(callback)
    .catch =>
      alert 'Loading the exercises failed.'

  createExerciseViewModel: (e) -> new ExerciseViewModel(e)

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
