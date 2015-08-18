// for apiMethod see tutor-server rest folder (exercises.coffee, ...)

module.exports = function(DB) {
  return [
    { path: '/api/exercises', dataCall: DB.Student.getExercises, apiMethod: "getExercises" },
    { path: '/api/exercises/active', dataCall: DB.Student.getAllActiveExercises, apiMethod: "getAllActiveExercises" },
    { path: '/api/exercises/detailed/:id', dataCall: DB.Student.getDetailedExercise, apiMethod: "getDetailedExercise" },
    { path: '/api/exercises/:id', dataCall: DB.Student.getExerciseById, apiMethod: "getExerciseById" }
    //{ path: '/api/exercises/', dataCall: DB.Student.putExercise, apiMethod: "putExerciseById" }
  ];
};
