ko = require 'knockout'
_ = require 'lodash'
app = require '../../app'
api = require '../../api'
UserViewModel = require('../../common/viewmodels').UserViewModel
GroupViewModel = require('../../common/viewmodels').GroupViewModel

class ViewModel
  constructor: ->
    @currentGroup = ko.computed => app.user().group()

    @canLeaveGroup = ko.computed =>
      @currentGroup().users.length > 1 or @currentGroup().pendingUsers.length > 0

    @invitations = ko.observableArray()
    api.get.invitations()
    .then (groups) =>
      @invitations groups.map (group) -> new GroupViewModel group

    @users = ko.observableArray()
    @selectedUsers = ko.observableArray()

    @search = ko.observable ''
    @displayedUsers = ko.computed =>
      users = _.filter @users(), (user) =>
        user.pseudonym().toLowerCase().indexOf(@search().toLowerCase()) >= 0
      _.take users, 20

    api.get.pseudonyms()
    .then (pseudonyms) =>
      @users pseudonyms.map (p) => new UserViewModel p
      @add _.find @users(), @isMe
    .catch (e) -> alert('Could not get pseudonyms.')

  add: (user) ->
    @users.remove user
    @selectedUsers.push user

  remove: (user) ->
    @selectedUsers.remove user
    @users.push user

  save: ->
    api.create.group users: _.map @selectedUsers(), (u) -> u.pseudonym()
    .then (group) =>
      ko.mapping.fromJS group, app.user().group #updates the group of the user object
      alert 'Invitations sent.'
    .catch (e) ->
      alert 'The group could not be created.'

  leave: ->
    api.create.group users: [app.user().pseudonym()]
    .then (group) =>
      ko.mapping.fromJS group, app.user().group #updates the group of the user object
    .catch (e) ->
      alert 'Leaving the group failed.'

  join: (group) ->
    api.post.joinGroup(group.id)
    .then =>
      ko.mapping.fromJS (ko.mapping.toJS group), app.user().group
      @invitations.remove group
    .catch (e) -> console.log e #-> alert 'Joining the group failed.'

  reject: (group) ->
    api.post.rejectGroup(group.id)
    .then => @invitations.remove group

  isMe: (user) ->
    app.user() && app.user().pseudonym && user.pseudonym() is app.user().pseudonym()

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
