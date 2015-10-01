ko = require 'knockout'
require 'knockout-mapping'
#not_found = './pages/not_found'
i18n = require 'i18next-ko'
md5 = require 'js-md5'
Router = require './router'

ko.components.register 'page-not-found', template: "<h2>Page not found</h2>"

class ViewModel
  constructor: ->
    @user = ko.observable()
    @isLoggedIn = ko.computed => @user()?
    @avatarUrl = ko.computed =>
      if @isLoggedIn() then "http://www.gravatar.com/avatar/#{md5(@user().pseudonym())}?d=wavatar"

    @availableLanguages = ['en']
    @language = ko.observable 'en'
    @language.subscribe (v) -> i18n.setLanguage v

    @router = new Router()

i18n.init {
  en:
    translation: require '../i18n/en'
  }, 'en', ko

module.exports = new ViewModel()
