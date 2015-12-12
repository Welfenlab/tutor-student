ko = require 'knockout'
api = require '../../api'
app = require '../../app'
ExerciseList = require('@tutor/exercise-list')(ko)
serverTime = require '../../util/servertime'

class ExerciseViewModel extends ExerciseList.ExerciseViewModel
  constructor: (data) ->
    super(data)

  show: -> app.goto 'exercise/' + @id

class ViewModel extends ExerciseList.OverviewPageViewModel
  constructor: ->
    super()

    @exercisesActive = ko.computed =>
      @exercises().filter (ex) =>
        Date.parse(ex.dueDate()) > serverTime()

    @exercisesPrevious = ko.computed =>
      @exercises().filter (ex) =>
        Date.parse(ex.dueDate()) < serverTime()

    @pointsPercentage = ko.computed =>
      sum = @exercisesPrevious()
      .map((e) -> e.points / e.maxPoints)
      .reduce(((a, b) -> a + b), 0)
      if sum == 0
        return 0
      else
        return sum / @exercisesPrevious().length
    @pointsPercentageStyle = ko.computed => "#{@pointsPercentage()}%"

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
