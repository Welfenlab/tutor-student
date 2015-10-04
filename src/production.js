
// initialize the production environment
module.exports = function(app, config){
  console.log("production environment");
  var rethinkDB = require("@tutor/rethinkdb-database")(config);


  config.modules = []

  return rethinkDB.then(function(DB){
    restAPI = require("./rest")(DB);
    config.modules.push(require("@tutor/saml")(DB.Users.create));
    resolve(restAPI);
  });
}
