Q = require 'q'

host = window.location.host.toString().split(":");
address = 'http://'+host[0]+':8080/api'

ajax = (method, url, data) ->
  Q $.ajax
    url: address + url
    data: data
    method: method

get = ajax.bind undefined, 'GET'
put = ajax.bind undefined, 'PUT'
post = ajax.bind undefined, 'POST'
del = ajax.bind undefined, 'DELETE'

api =
  get:
    exercises: -> get('/exercises')
    exercise: (id) -> get("/exercises/#{id}")
    me: -> get('/user')
    group: -> get('/group')
    pseudonyms: -> get('/pseudonyms')
  put:
    exercise: (id, content) -> put "/exercises/#{id}", content
  post:
    login: (id) -> post "/login",
        id: id

module.exports = api
