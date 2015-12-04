ko = require 'knockout'
api = require '../../api'
mdeditor = require './mdeditor'
moment = require 'moment'
_ = require 'lodash'
serverTime = require '../../util/servertime'
require '@tutor/task-preview'

class TaskViewModel
  constructor: (data) ->
    if data?
      ko.mapping.fromJS data, {}, this
    if not @prefilled
      @prefilled = ko.observable ''
    @hasTitle = ko.computed => @title()? and @title().trim() isnt ''
    @solution or= ko.observable ''
    @editor = ko.observable()
    @testResults = ko.observable([])

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
    @selectedTaskIndex = ko.observable(-1)
    @selectedTask = ko.computed =>
      if @selectedTaskIndex() >= 0
        @tasks()[@selectedTaskIndex()]
    @title = ko.computed => @exercise().title
    @exerciseNotFound = ko.observable(no)

    @allTests = ko.computed =>
      @tasks().map((task) -> task.testResults())

    @tests = ko.computed =>
      if @selectedTaskIndex() >= 0
        @allTests()[@selectedTaskIndex()]
      else
        _.flattenDeep(@allTests())
    @failedTests = ko.computed => _.reject @tests(), 'passes'

    @isOld = ko.computed => Date.parse(@exercise().dueDate) < serverTime()
    @timeLeft = ko.computed =>
      moment(@exercise().dueDate).from(serverTime(), true)

    @isOld.subscribe (value) =>
      # this is updated after this subscription, so it will also be called
      # for exercises that are already due
      if value #disable editor after due date
        t.destroy() for t in @tests()

    api.get.group()
    .then (group) =>
      @group = group
    .then -> api.get.exercise params.id
    .then (exercise) =>
      if(Date.parse(exercise.dueDate) >= @serverTime)
        api.post.solution exercise.id
      return exercise
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

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
