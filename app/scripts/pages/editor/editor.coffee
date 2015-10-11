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
    @editor = ko.observable()

    @saved = ko.observable true
    @connected = ko.observable true

    @editor.subscribe (editor) =>
      editor.on 'connect', => @connected true
      editor.on 'disconnect', => @connected false
      editor.on 'save', => @saved true
      editor.on 'unsavedChanges', => @saved false

  destroy: ->
    if @editor()
      @editor().destroy()

class ViewModel
  constructor: (params) ->
    @exercise = ko.observable({})
    @number = ko.computed => @exercise().number
    @tasks = ko.computed => _.map @exercise().tasks, (t) -> new TaskViewModel t
    @saved = ko.computed => _.every @tasks(), (t) -> t.saved()
    @connected = ko.computed => _.every @tasks(), (t) -> t.connected()
    @selectedTaskIndex = ko.observable -1 #TODO set this to -1 if no task is focused, or to the index of the focused task
    @selectedTask = ko.computed =>
      if @selectedTaskIndex() >= 0
        @tasks()[@selectedTaskIndex()]
    @title = ko.computed => @exercise().title
    @exerciseNotFound = ko.observable(no)

    @allTests = ko.observableArray()
    @tests = ko.computed =>
      if @selectedTaskIndex() >= 0
        @allTests()[@selectedTaskIndex()]
      _.flattenDeep(@allTests())
    @failedTests = ko.computed => _.reject @tests(), 'passes'

    @exercise.subscribe =>
      #TODO initialize the array like this later:
      #@tests new Array(@exercise().tasks.length).map(-> [])
      @allTests [
        [
          {
            name: 'Solution should be correct.'
            passes: false
          },
          {
            name: 'This test should fail (paradoxon, lol).'
            passes: true
          }
        ]
        [
          {
            name: 'Solution should be correct.'
            passes: false
          },
          {
            name: 'This checkmark should be green.'
            passes: true
          }
        ]
        [
          {
            name: 'Solution should be correct.'
            passes: false
          }
        ]
      ]

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
    $('#showtests').popup(inline: true)

  initTask: (task, element) =>
    ko.utils.domNodeDisposal.addDisposeCallback element, task.destroy.bind(task)
    task.editor mdeditor task, @group, @theExercise, @allTests, @selectedTaskIndex
    markdown()('text-'+task.number()).render(task.text())
    markdown()('text-sol-'+task.number()).render(task.text())

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
