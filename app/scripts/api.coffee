{get, put, post, del, address} = require('@tutor/app-base').api
Q = require('q')

module.exports =
  get:
    exercises: -> get('/exercises')
    exercise: (id) -> get("/exercises/#{id}")
    me: -> get('/user')
    group: -> get('/group')
    pseudonyms: -> get('/pseudonyms')
    pseudonym: -> get('/generatepseudonym')
    time: -> get('/time')
    logindata: -> get('/login_data')
    invitations: -> get('/group/pending')
    config: -> get('/config')
  put:
    exercise: (id, content) -> put "/exercises/#{id}", content
    pseudonym: (pseudonym) -> put "/user/pseudonym", pseudonym: pseudonym
  post:
    loginDev: (id) -> post "/login",
        id: id
        password: ""
    solution: (exercise_id) -> post '/solution',
        exercise: exercise_id
    joinGroup: (id) -> post '/group/join', group: id
    rejectGroup: (id) -> post '/group/join', group: id
  logout: -> post '/logout'
  create:
    group: (members) -> post '/group', members
  urlOf:
    correctedExercise: (id) -> "#{address}/correction/pdf/#{id}"
    submittedExercise: (id) -> "#{address}/solution/pdf/#{id}"
  address: address
