
module.exports = function(DB){
  return [
    { path: '/api/exercises', dataCall: DB.Student.getExercises, apiMethod: "getExercises" },
    { path: '/api/exercises/:id', dataCall: DB.Student.getExercise, apiMethod: "getExerciseById" },
    { path: '/api/exercises/', dataCall: DB.Student.putExercise, apiMethod: "putExerciseById" }
  ];
};
