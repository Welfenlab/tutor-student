ko = require 'knockout'
require 'knockout-mapping'
_ = require 'lodash'
#not_found = './pages/not_found'
api = require './api'
wavatar = require('./util/gravatar').wavatar
GroupViewModel = require('./common/viewmodels').GroupViewModel
{TutorAppBase} = require '@tutor/app-base'

ko.components.register 'page-not-found', template: "<h2>Page not found</h2>"

class ViewModel extends TutorAppBase($, ko)
  constructor: ->
    super({
      mainElement: '#main'
      translations:
        en: require '../i18n/en'
    })
    @config = ko.observable({})
    @user = ko.observable({group: _.noop})
    @group = ko.computed => if @user().group then @user().group() else {}

    @isLoggedIn = ko.computed => @user()? and @user().pseudonym?
    @isLoggedIn.subscribe =>
      if @isLoggedIn()
        api.get.config().then (config) => @config config

    @avatarUrl = ko.computed =>
      if @isLoggedIn()
        wavatar @user().pseudonym()

    @isActiveObservable = (path) => ko.computed => @isActive(path)

    $ =>
      api.get.me()
      .then (me) =>
        user = ko.mapping.fromJS me
        user.group = ko.observable new GroupViewModel(me.group)
        @user user
        if @user().pseudonym().indexOf('Nameless Nobody') == 0
          @goto 'register'
        else
          @goto(localStorage.getItem('post-login-redirect') || @path(), true)
          localStorage.removeItem('post-login-redirect')
      .catch (e) =>
        localStorage.setItem('post-login-redirect', @path())
        @goto 'login'

  registerPopup: ->
    $('.button').popup(position: 'bottom right', hoverable: true, on: 'click')

  logout: ->
    api.logout()
    .then =>
      @user {}
      @goto 'login'
    .catch (e) -> console.log e

module.exports = new ViewModel()
