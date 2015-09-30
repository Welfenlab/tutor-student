ko = require 'knockout'
api = require '../../api'
markdown = require './markdown'
_ = require 'lodash'

class TaskViewModel
  constructor: (data) ->
    if data?
      ko.mapping.fromJS data, {}, this
    @hasTitle = ko.computed => @title()? and @title().trim() isnt ''
    @solution or= ko.observable ''

class ViewModel
  constructor: (params) ->
    @number = ko.observable()
    @tasks = ko.observableArray()
    @exerciseNotFound = ko.observable(no)
    @isOld = ko.observable true

    api.get.group()
    .then (group) =>
      @group = group
    .then -> api.get.exercise params.id
    .then (exercise) =>
      @exercise = exercise
      @number exercise.number

      @tasks _.map exercise.tasks, (t) ->
        task = new TaskViewModel t
        task.solution.subscribe => @submit t
        return task

      @isOld Date.parse(exercise.dueDate) < Date.now()
    .catch (e) ->
      console.log e
      alert 'an error occurred' #TODO add better error messages

  init: (task) =>
    markdown task, @group

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
