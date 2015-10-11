Q = require 'q'

host = window.location.host;
proto = window.location.protocol;
address = proto + '//'+host+'/api'

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
    time: -> get('/time')
  put:
    exercise: (id, content) -> put "/exercises/#{id}", content
    pseudonym: (pseudonym) -> put "/user/pseudonym", pseudonym: pseudonym
  post:
    login: (id) -> post "/login",
        id: id
        password: ""
    solution: (exercise_id) -> post "/solution",
        exercise: exercise_id
  logout: -> post '/logout'
  create:
    group: (members) -> post '/group', members

module.exports = api
