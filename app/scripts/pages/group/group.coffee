ko = require 'knockout'
md5 = require 'js-md5'
app = require '../../app'
api = require '../../api'

class UserViewModel
  constructor: (pseudonym, @parent) ->
    @pseudonym = ko.observable pseudonym
    @avatarUrl = "http://www.gravatar.com/avatar/#{md5(@pseudonym())}?d=wavatar"

  add: -> @parent.add this
  remove: -> @parent.remove this

class ViewModel
  constructor: ->
    @users = ko.observableArray()
    @selectedUsers = ko.observableArray()

    @search = ko.observable ''
    @displayedUsers = ko.computed =>
      @users().filter (user) =>
        user.pseudonym().toLowerCase().indexOf(@search().toLowerCase()) >= 0

    api.get.pseudonyms()
    .then (pseudonyms) => @users pseudonyms.map (p) => new UserViewModel(p, this)
    .catch (e) -> console.log e #-> alert('Could not get pseudonyms.')

  add: (user) ->
    @users.remove user
    @selectedUsers.push user

  remove: (user) ->
    @selectedUsers.remove user
    @users.push user

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
