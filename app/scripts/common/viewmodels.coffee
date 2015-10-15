ko = require 'knockout'
_ = require 'lodash'
wavatar = require('../util/gravatar').wavatar

class GroupViewModel
  constructor: (group) ->
    @id = group.id
    @users = ko.observableArray group.users.map (u) -> new UserViewModel u
    @pendingUsers = ko.observableArray group.pendingUsers.map (u) -> new UserViewModel u
    @allUsers = ko.computed => _.union @users(), @pendingUsers()

class UserViewModel
  constructor: (pseudonym) ->
    @pseudonym = ko.observable pseudonym
    @avatarUrl = ko.computed => wavatar @pseudonym()

module.exports =
  GroupViewModel: GroupViewModel
  UserViewModel: UserViewModel
