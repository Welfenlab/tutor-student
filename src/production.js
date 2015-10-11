
var express = require("express");

// initialize the production environment
module.exports = function(config){
  console.log("production environment");
  console.log("... waiting 10s for RethinkDB");
  config.database.host = process.env.RETHINKDB_PORT_28015_TCP_ADDR;
  config.database.port = parseInt(process.env.RETHINKDB_PORT_28015_TCP_PORT);
  config.sharejs.rethinkdb.host = config.database.host;
  config.sharejs.rethinkdb.port = config.database.port;
  console.log("database connection: " + config.database.host + ":" + config.database.port);
  return new Promise(function(resolve){
    setTimeout(function(){
      resolve();
    },10000);
  }).then(function(){
    var rethinkDB = require("@tutor/rethinkdb-database")(config);


    config.modules = []

    return rethinkDB.then(function(DB){
      restAPI = require("./rest")(DB);
      config.modules.push(require("@tutor/saml")(DB.Users.create, DB.Users.exists,
          function(){return Promise.resolve()} ));
      config.modules.push(function(app, config){
        app.use(express.static('./build'));
      });
      return {api: restAPI, db: DB};
    });
  });
}
