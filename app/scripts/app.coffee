ko = require 'knockout'
require 'knockout-mapping'
_ = require 'lodash'
#not_found = './pages/not_found'
i18n = require 'i18next-ko'
Router = require './router'
api = require './api'
wavatar = require('./util/gravatar').wavatar
GroupViewModel = require('./common/viewmodels').GroupViewModel

ko.components.register 'page-not-found', template: "<h2>Page not found</h2>"

class ViewModel
  constructor: ->
    @router = new Router()
    @isActive = (path) => ko.computed => @router.path().indexOf(path) == 0

    @user = ko.observable({group: _.noop})
    @group = ko.computed => if @user().group then @user().group() else {}

    @isLoggedIn = ko.computed => @user()? and @user().pseudonym?
    @avatarUrl = ko.computed =>
      if @isLoggedIn()
        wavatar @user().pseudonym()

    @availableLanguages = ['en']
    @language = ko.observable 'en'
    @language.subscribe (v) -> i18n.setLanguage v

    @load()

  load: ->
    api.get.me()
    .then (me) =>
      user = ko.mapping.fromJS me
      user.group = ko.observable new GroupViewModel(me.group)
      @user user
      @router.goto location.hash.substr(1) #go to the page the user wants to go to
    .catch (e) => console.log(e) ; @router.goto 'login'

  registerPopup: ->
    $('.button').popup(position: 'bottom right', hoverable: true)

  logout: ->
    api.logout()
    .then =>
      @user {}
      @router.goto 'login'
    .catch (e) -> console.log e

i18n.init {
  en:
    translation: require '../i18n/en'
  }, 'en', ko

module.exports = new ViewModel()
