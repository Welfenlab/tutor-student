ko = require 'knockout'
api = require '../api'

timeDifference = ko.observable 0
localTime = ko.observable Date.now()

update = ->
  api.get.time()
  .then (time) ->
    timeDifference(Date.parse(time) - Date.now())
  .finally ->
    setTimeout(update, 10 * 60 * 1000) #10 minutes
update()

updateLocalTime = -> localTime Date.now()
setInterval(updateLocalTime, 1000)

module.exports = ko.computed => localTime() + timeDifference()
