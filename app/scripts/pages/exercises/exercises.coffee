ko = require 'knockout'
moment = require 'moment'
api = require '../../api'
app = require '../../app'
ExerciseList = require('@tutor/exercise-list')(ko)
serverTime = require '../../util/servertime'

class ExerciseViewModel extends ExerciseList.ExerciseViewModel
  constructor: (data) ->
    super(data)
    @isCorrected = data.corrected
    @formattedDueDateText = moment(data.dueDate).from(Date.now())

  show: -> app.goto 'exercise/' + @id

  downloadPdf: (data, event) ->
    if event
      event.stopPropagation()

    if @isCorrected
      window.open("#{api.address}/correction/pdf/#{@id}", '_blank')
    else
      window.open("#{api.address}/solution/pdf/#{@id}", '_blank')

class ViewModel extends ExerciseList.OverviewPageViewModel
  constructor: ->
    super()

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

  getExercises: (callback) ->
    api.get.exercises()
    .then(callback)
    .catch (e) =>
      alert 'Loading the exercises failed.'

  createExerciseViewModel: (e) -> new ExerciseViewModel(e)

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
