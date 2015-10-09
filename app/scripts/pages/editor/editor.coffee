ko = require 'knockout'
api = require '../../api'
mdeditor = require './mdeditor'
markdown = require './markdown'
moment = require 'moment'
_ = require 'lodash'

class TaskViewModel
  constructor: (data) ->
    if data?
      ko.mapping.fromJS data, {}, this
    if not @prefilled
      @prefilled = ko.observable ''
    @hasTitle = ko.computed => @title()? and @title().trim() isnt ''
    @solution or= ko.observable ''

class ViewModel
  constructor: (params) ->
    @exercise = ko.observable({})
    @number = ko.computed => @exercise().number
    @tasks = ko.computed => _.map @exercise().tasks, (t) -> new TaskViewModel t
    @title = ko.computed => @exercise().title
    @exerciseNotFound = ko.observable(no)
    @tests = ko.observableArray()
    @exercise.subscribe =>
      #TODO initialize the array like this later:
      #new Array(@exercise().tasks.length).map(-> [])
      taskTests = new Array(@exercise().tasks.length).map(-> [])
      for tests in taskTests
        tests.push
          description: 'Solution should be correct.'
          passes: true
        tests.push
          description: 'This test should fail (paradoxon, lol).'
          passes: false
      @tests taskTests

    @timeDifference = ko.observable 0
    @localTime = ko.observable Date.now()
    @serverTime = ko.computed => @localTime() + @timeDifference()

    @isOld = ko.computed => Date.parse(@exercise().dueDate) < @serverTime()
    @timeLeft = ko.computed =>
      moment(@exercise().dueDate).from(@serverTime(), true)

    @updateServertimeInterval = setInterval(=>
      api.get.time().then (time) =>
        @timeDifference(Date.parse(time) - Date.now())
    , 5 * 60 * 1000) #every five minutes
    @updateLocalTimeInterval = setInterval(=>
      @localTime Date.now()
    , 1000)

    api.get.group()
    .then (group) =>
      @group = group
    .then -> api.get.exercise params.id
    .then (exercise) =>
      @theExercise = exercise
      @exercise exercise
    .catch (e) ->
      console.log e
      alert 'an error occurred' #TODO add better error messages

  init: ->


  initTask: (task) =>
    mdeditor task, @group, @theExercise
    markdown('text-'+task.number()).render(task.text())
    markdown('text-sol-'+task.number()).render(task.text())

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
