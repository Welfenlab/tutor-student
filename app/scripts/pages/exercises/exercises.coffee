ko = require 'knockout'
moment = require 'moment'
api = require '../../api'
app = require '../../app'
serverTime = require '../../util/servertime'

class ExerciseViewModel
  constructor: (data) ->
    @id = data.id
    @number = data.number
    @dueDate = ko.observable new Date(Date.parse(data.dueDate))
    @formattedDueDate = ko.computed => @dueDate().toLocaleDateString()
    @formattedDueDateText = ko.computed => moment(data.dueDate).from(serverTime())

    @points = 2
    @maxPoints = data.tasks.reduce ((sum, task) -> sum + parseInt(task.maxPoints)), 0

    @isOld = ko.computed => @dueDate().getTime() < serverTime()
    @isCorrected = data.corrected

  show: -> app.goto 'exercise/' + @id

  downloadPdf: (data, event) ->
    if event
      event.stopPropagation()

    if @isCorrected
      window.open("#{api.address}/correction/pdf/#{@id}", '_blank')
    else
      window.open("#{api.address}/solution/pdf/#{@id}", '_blank')

class ViewModel
  constructor: ->
    @exercises = ko.observableArray()

    exerciseSorter = (a, b) ->
      if a.isOld()
        return if b.isOld() then 0 else 1
      else
        return if b.isOld() then 1 else 0

    api.get.exercises()
    .then (exercises) =>
      @exercises exercises.map((e) -> new ExerciseViewModel(e)).sort(exerciseSorter)
    .catch (e) =>
      alert 'Loading the exercises failed.'

    @exercisesActive = ko.computed =>
      @exercises().filter (ex) =>
        Date.parse(ex.dueDate()) > serverTime()

    @exercisesPrevious = ko.computed =>
      @exercises().filter (ex) =>
        Date.parse(ex.dueDate()) < serverTime()

    @correctedExercises = ko.computed =>
      @exercisesPrevious().filter (ex) => ex.isCorrected

    @pointsPercentage = ko.computed =>
      sum = @exercisesPrevious()
      .map((e) -> (e.points / e.maxPoints) | 0)
      .reduce(((a, b) -> a + b), 0)
      if sum == 0
        return 0
      else
        return sum / @correctedExercises().length
    @pointsPercentageStyle = ko.computed => "#{@pointsPercentage()}%"
    @bonusPercentage = ko.computed => (app.config().bonusPercentage || 0)

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
