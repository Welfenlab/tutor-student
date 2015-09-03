// for apiMethod see tutor-server rest folder (exercises.coffee, ...)

module.exports = function(DB) {
  return [
    { path: '/api/exercises', dataCall: DB.Student.getExercises, apiMethod: "get" },
    { path: '/api/exercises/active', dataCall: DB.Student.getAllActiveExercises, apiMethod: "get" },
    { path: '/api/exercises/detailed/:id', dataCall: DB.Student.getDetailedExercise, apiMethod: "getByParam", param: "id" },
    { path: '/api/exercises/:id', dataCall: DB.Student.getExerciseById, apiMethod: "getByParam", param: "id" },
    { path: '/api/total', dataCall: DB.Student.getTotalPoints, apiMethod: "getBySessionUID" },

    { path: '/api/user/pseudonym', dataCall: DB.Student.getUserPseudonym, apiMethod: "getBySessionUID" },
    { path: '/api/user/pseudonym', dataCall: DB.Student.setUserPseudonym, apiMethod: "putBySessionUIDAndBodyParam", param: "pseudonym" },
    { path: '/api/user/group', dataCall: DB.Student.getGroupForUser, apiMethod: "getBySessionUID" },
    { path: '/api/user/', dataCall: function(id, res){
        DB.Student.getGroupForUser(id, function(err,group){
          if(err){
            res(err)
            return;
          }
          DB.Student.getUserPseudonym(id, function(err,pseudonym){
            if(err)
              res(err);
            else
              res(null,{id: id, group: group, pseudonym: pseudonym});
          });
        });
      }, apiMethod: "getBySessionUID"
    },
    { path: '/api/pseudonyms', dataCall: DB.Student.getPseudonymList, apiMethod: "get" },

    { path: '/api/group', dataCall: DB.Student.createGroup, apiMethod: "postByBodyParam", param: "ids" }
  ];
};
