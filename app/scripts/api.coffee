address = 'http://localhost:8080/api'

ajax = (method, url, data, callback) ->
  # data is optional
  if typeof data is 'function'
    callback = data
    data = {}

  $.ajax
    url: address + url
    data: data
    method: method
  .done (data, status) ->
    callback(data, status) if callback?
  .fail (jqxhr, status, error) ->
    callback(undefined, status, error) if callback?

get = (u, d, c) -> ajax 'GET', u, d, c
put = (u, d, c) -> ajax 'PUT', u, d, c
post = (u, d, c) -> ajax 'POST', u, d, c
del = (u, d, c) -> ajax 'DELETE', u, d, c

api =
  get:
    exercises: (c) -> get('/exercises', c)
    exercise: (id, c) -> get("/exercises/#{id}", c)
  put:
    exercise: (id, content, c) -> put("/exercises/#{id}", content, c)
  post:
#    login: (uuid, c) -> post("/login/#{uuid}", c)
    login: (uuid, c) -> post "/login", c

module.exports = api
