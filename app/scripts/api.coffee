Q = require 'q'

host = window.location.host;
proto = window.location.protocol;
address = proto + '//'+host+'/api'

ajax = (method, url, data, relative = true) ->
  Q $.ajax
    url: if relative then address + url else url
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
    logindata: -> get('/login_data')
  put:
    exercise: (id, content) -> put "/exercises/#{id}", content
    pseudonym: (pseudonym) -> put "/user/pseudonym", pseudonym: pseudonym
  post:
    loginDev: (id) -> post "/login",
        id: id
        password: ""
    solution: (exercise_id) -> post "/solution",
        exercise: exercise_id
  logout: -> post '/logout'
  create:
    group: (members) -> post '/group', members

module.exports = api
