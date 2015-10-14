ko = require 'knockout'
md5 = require 'js-md5'
_ = require 'lodash'
app = require '../../app'
api = require '../../api'
wavatar = require('../../util/gravatar').wavatar

class UserViewModel
  constructor: (pseudonym, @parent) ->
    @pseudonym = ko.observable pseudonym
    @avatarUrl = wavatar @pseudonym()
    @isMe = ko.computed => app.user().pseudonym && @pseudonym() is app.user().pseudonym()

  add: -> @parent.add this
  remove: -> @parent.remove this

class ViewModel
  constructor: ->
    @currentGroup = ko.computed =>
      members = if app.user().group then app.user().group else []

      pending: members.pendingUsers().map (m) => new UserViewModel m, this
      users: members.users().map (m) => new UserViewModel m, this

    @users = ko.observableArray()
    @selectedUsers = ko.observableArray()

    @search = ko.observable ''
    @displayedUsers = ko.computed =>
      users = _.filter @users(), (user) =>
        user.pseudonym().toLowerCase().indexOf(@search().toLowerCase()) >= 0
      _.take users, 20

    api.get.pseudonyms()
    .then (pseudonyms) =>
      @users pseudonyms.map (p) => new UserViewModel(p, this)
      @add _.find @users(), (user) -> user.isMe()
    .catch (e) -> console.log e #-> alert('Could not get pseudonyms.')

  add: (user) ->
    @users.remove user
    @selectedUsers.push user

  remove: (user) ->
    @selectedUsers.remove user
    @users.push user

  save: ->
    api.create.group _.map @users(), (u) -> u.pseudonym()
    .then (group) =>
      ko.mapping.fromJS group, app.user().group #updates the group of the user object
      alert 'Invitations sent.'
    .catch (e) ->
      alert 'The group could not be created.'

  leave: ->
    #TODO can't be implemented at the moment, see #30

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
