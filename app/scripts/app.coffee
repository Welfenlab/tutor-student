ko = require 'knockout'
require 'knockout-mapping'
_ = require 'lodash'
#not_found = './pages/not_found'
i18n = require 'i18next-ko'
api = require './api'
wavatar = require('./util/gravatar').wavatar
GroupViewModel = require('./common/viewmodels').GroupViewModel

ko.components.register 'page-not-found', template: "<h2>Page not found</h2>"

class ViewModel
  constructor: ->
    @page = ko.observable()
    @pageParams = ko.observable({})
    @pageRequiresLogin = ko.observable(true)
    @path = ko.observable('')
    @isActive = (path) => ko.computed => @path().indexOf(path) == 0

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
      @goto location.hash
    .catch (e) => console.log(e) ; @goto 'login'

  registerPopup: ->
    $('.button').popup(position: 'bottom right', hoverable: true, on: 'click')

  logout: ->
    api.logout()
    .then =>
      @user {}
      @goto 'login'
    .catch (e) -> console.log e

  goto: (v, replace) ->
    mainElement = document.getElementById('main')?.firstChild
    if mainElement
      pageComponent = ko.dataFor mainElement
      if pageComponent and pageComponent.onBeforeHide
        if pageComponent.onBeforeHide() is false
          return
    if v.indexOf('/') == 0
      v = v.substr(1)

    if replace
      require('page').replace "/#{v}", replace
    else
      require('page').show "/#{v}"

i18n.init {
  en:
    translation: require '../i18n/en'
  }, 'en', ko

module.exports = new ViewModel()
