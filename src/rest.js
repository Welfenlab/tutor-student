// for apiMethod see tutor-server rest folder (exercises.coffee, ...)

module.exports = function(DB) {
  return [
    { path: '/api/exercises', dataCall: DB.Exercises.get, apiMethod: "get" },
    { path: '/api/exercises/active', dataCall: DB.Exercises.getAllActive, apiMethod: "get" },
    { path: '/api/exercises/detailed/:id', dataCall: DB.Exercises.getDetailed, apiMethod: "getByParam", param: "id" },
    { path: '/api/exercises/:id', dataCall: DB.Exercises.getById, apiMethod: "getByParam", param: "id" },
    { path: '/api/total', dataCall: DB.Exercises.getTotalPoints, apiMethod: "getBySessionUID" },

    { path: '/api/user/pseudonym', dataCall: DB.Users.getPseudonym, apiMethod: "getBySessionUID" },
    { path: '/api/user/pseudonym', dataCall: DB.Users.setPseudonym, apiMethod: "putBySessionUIDAndBodyParam", param: "pseudonym" },
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
    { path: '/api/group', dataCall: DB.Groups.create, apiMethod: "postBySessionUIDAndBodyParam", param: "ids" },
    { path: '/api/group/join', dataCall: DB.Groups.joinGroup, apiMethod: "postBySessionUIDAndBodyParam", param: "group" },
    { path: '/api/group/pending', dataCall: DB.Groups.pending, apiMethod: "getBySessionUID"},
    { path: '/api/group/reject', dataCall: DB.Groups.rejectInvitation, apiMethod: "postBySessionUIDAndBodyParam", param: "group"}
  ];
};
