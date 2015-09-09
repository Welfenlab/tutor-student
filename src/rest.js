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
    { path: '/api/user/', dataCall: function(id, res){
        DB.Student.getGroupForUser(id).then(function(group){
          DB.Student.getPseudonym(id, function(pseudonym){
            res(null,{id: id, group: group, pseudonym: pseudonym});
          }).catch(function(err){ res(err);});
        }).catch(function(err){ res(err);});
      }, apiMethod: "getBySessionUID"
    },
    { path: '/api/pseudonyms', dataCall: DB.Users.getPseudonymList, apiMethod: "get" },

    { path: '/api/group', dataCall: DB.Groups.getGroupForUser, apiMethod: "getBySessionUID" },
    { path: '/api/group', dataCall: DB.Groups.createGroup, apiMethod: "postBySessionUIDAndBodyParam", param: "ids" }
  ];
};
