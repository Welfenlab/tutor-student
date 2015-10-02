ko = require 'knockout'
require 'knockout-mapping'
#not_found = './pages/not_found'
i18n = require 'i18next-ko'
md5 = require 'js-md5'
Router = require './router'
api = require './api'

ko.components.register 'page-not-found', template: "<h2>Page not found</h2>"

class ViewModel
  constructor: ->
    @router = new Router()

    @user = ko.observable({})
    api.get.me()
    .then (me) =>
      @user ko.mapping.fromJS me
      @router.goto location.hash.substr(1) #go to the page the user wants to go to
    .catch (e) => @router.goto 'login'

    @isLoggedIn = ko.computed => @user()? and @user().pseudonym?
    @avatarUrl = ko.computed =>
      if @isLoggedIn() then "http://www.gravatar.com/avatar/#{md5(@user().pseudonym())}?d=wavatar&f=y"

    @availableLanguages = ['en']
    @language = ko.observable 'en'
    @language.subscribe (v) -> i18n.setLanguage v

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
