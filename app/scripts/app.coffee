ko = require 'knockout'
require 'knockout-mapping'
#not_found = './pages/not_found'
i18n = require 'i18next-ko'
md5 = require 'js-md5'
Router = require './router'
api = require './api'
wavatar = require('./util/gravatar').wavatar

ko.components.register 'page-not-found', template: "<h2>Page not found</h2>"

class ViewModel
  constructor: ->
    @router = new Router()

    @user = ko.observable({})

    @isLoggedIn = ko.computed => @user()? and @user().pseudonym?
    @avatarUrl = ko.computed =>
      if @isLoggedIn()
        wavatar @user().pseudonym()

    @availableLanguages = ['en']
    @language = ko.observable 'en'
    @language.subscribe (v) -> i18n.setLanguage v

    api.get.me()
    .then (me) =>
      mappedUser = ko.mapping.fromJS me
      mappedUser.group.users mappedUser.group.users().map (member) ->
        name: member
        avatarUrl: wavatar member
      @user mappedUser
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
