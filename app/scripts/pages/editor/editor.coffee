ko = require 'knockout'
api = require '../../api'
markdown = require './markdown'
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

    @timeDifference = ko.observable 0
    @localTime = ko.observable Date.now()
    @serverTime = ko.computed => @localTime() + @timeDifference()

    @isOld = ko.computed => Date.parse(@exercise().dueDate) < @serverTime()
    @timeLeft = ko.computed =>
      delta = @serverTime() - Date.parse(@exercise().dueDate)
      days = delta / (24 * 60 * 60 * 1000)
      delta %= 24 * 60 * 60 * 1000
      hours = delta / (60 * 60 * 1000)
      delta %= 60 * 60 * 1000
      minutes = delta / (60 * 1000)
      delta %= 60 * 1000
      seconds = delta / 1000
      if days > 0
        "#{days|0} days and #{hours|0} hours"
      else if hours > 0
        "#{hours|0} hours and #{minutes|0} minutes"
      else
        "#{minutes|0} minutes and #{seconds|0} seconds"

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
      @exercise exercise
    .catch (e) ->
      console.log e
      alert 'an error occurred' #TODO add better error messages

  init: ->


  initTask: (task) =>
    markdown task, @group

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
