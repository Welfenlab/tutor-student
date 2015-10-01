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
    pseudonym: -> get('/generatepseudonym')
  put:
    exercise: (id, content) -> put "/exercises/#{id}", content
    pseudonym: (pseudonym) -> put "/user/pseudonym", pseudonym: pseudonym
  post:
    login: (id) -> post "/login",
        id: id
  create:
    group: (members) -> post '/group', members

module.exports = api
