ko = require 'knockout'

rename = (array, names) ->
  obj = {}
  for item, i in array
    obj[names[i]] = item
  return obj

class Router
  constructor: ->
    @path = ko.observable ''
    @parameters = ko.observable {}
    @selected = ko.observable null
    @pages = ko.observableArray()

  goto: (v) ->
      found = no
      result = null
      for page in @pages()
        if page.path is v or (result = v.match page.path) isnt null
          if result?
            @parameters rename result.slice(1), page.as
          else
            @parameters {}
          @selected page.component
          found = yes
          break

      if not found
        @selected 'page-not-found'

      history.pushState(null, '', '#' + v)

module.exports = Router
