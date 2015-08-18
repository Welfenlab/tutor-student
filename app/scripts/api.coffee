address = 'http://localhost:8080/api'

ajax = (method, url, data) ->
  $.ajax
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
  put:
    exercise: (id, content) -> put "/exercises/#{id}", content
  post:
    login: (uuid) -> post "/login",
        uuid: uuid

module.exports = api
