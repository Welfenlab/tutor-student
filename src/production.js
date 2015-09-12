

// initialize the production environment
module.exports = function(app, config){
  var rethinkDB = require("@tutor/rethinkdb-database")(config);

  restAPI = require("./rest")(rethinkDB);

  config.modules = []
  config.modules.push(require("@tutor/saml"));

  return restAPI;
}
