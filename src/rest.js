// for apiMethod see tutor-server rest folder (exercises.coffee, ...)

module.exports = function(DB) {
  return [
    { path: '/api/exercises', dataCall: DB.Exercises.get, apiMethod: "get" },
    { path: '/api/exercises/active', dataCall: DB.Exercises.getAllActive, apiMethod: "get" },
    { path: '/api/exercises/detailed/:id', dataCall: DB.Exercises.getDetailed, apiMethod: "getByParam", param: "id" },
    { path: '/api/exercises/:id', dataCall: DB.Exercises.getById, apiMethod: "getByParam", param: "id" },
    { path: '/api/total', dataCall: DB.Exercises.getTotalPoints, apiMethod: "getBySessionUID" },

    { path: '/api/user/pseudonym', dataCall: DB.Users.getPseudonym, apiMethod: "getBySessionUID" },
    { path: '/api/user/pseudonym', dataCall: DB.Users.setPseudonym, apiMethod: "putBySessionUIDAndParam", param: "pseudonym", errStatus: 409 },
    { path: '/api/user/group', dataCall: DB.Groups.getGroupForUser, apiMethod: "getBySessionUID" },
    { path: '/api/user', dataCall: function(id){
      return Promise.all([
          DB.Groups.getGroupForUser(id),
          DB.Users.getPseudonym(id)]).then(function(values){
            return {group: values[0], pseudonym: values[1], id: id};
          });
      }, apiMethod: "getBySessionUID"
    },
    { path: '/api/pseudonyms', dataCall: DB.Users.getPseudonymList, apiMethod: "get" },

    { path: '/api/group', dataCall: DB.Groups.getGroupForUser, apiMethod: "getBySessionUID" },
    { path: '/api/group', dataCall: DB.Groups.create, apiMethod: "postBySessionUIDAndParam", param: "users" },
    { path: '/api/group/join', dataCall: DB.Groups.joinGroup, apiMethod: "postBySessionUIDAndParam", param: "group" , errStatus: 401 },
    { path: '/api/group/pending', dataCall: DB.Groups.pending, apiMethod: "getBySessionUID"},
    { path: '/api/group/reject', dataCall: DB.Groups.rejectInvitation, apiMethod: "postBySessionUIDAndParam", param: "group"},

    { path: '/api/solution/:id', dataCall: DB.Exercises.getExerciseSolution, apiMethod: "getBySessionUIDAndParam", param: "id", errStatus: 404 },
    { path: '/api/solution/', dataCall: DB.Exercises.setExerciseSolution, apiMethod: "putBySessionUIDAndParams", params: ["exercise","solution"], errStatus: 404 },
  ];
};
