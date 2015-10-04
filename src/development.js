var express = require("express");
var _ = require("lodash");

// initialize the development environment
module.exports = function(config){
  var configureServer = function(API, DB, userlogin){
    config.modules.push(require("@tutor/dummy-auth")(userlogin));
    config.domainname = "tutor.gdv.uni-hannover.de"
    //config.modules.push(require("@tutor/saml"));

    config.modules.push(function(app, config){
      app.use(express.static('./build'));
      // enable cors for development (REST API over Swagger)
      app.use(function(req, res, next) {
        res.header("Access-Control-Allow-Origin", "*");
        res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
        next();
      });
      app.use(require('morgan')('dev'));
    });
    return Promise.resolve()
  };

  // make sure to start with an empty config!
  config.modules = []

  // use memdb!
  if(!config.devrdb){
    console.log("### development environment ###");
    var MemDB = require("@tutor/memory-database")(config);
    restAPI = require("./rest")(MemDB);
    return new Promise(function(resolve){
      configureServer(restAPI, MemDB, MemDB.Users.exists);
      resolve(restAPI);
    });
  } else {
    console.log("### development environment with RethinkDB @" +
      config.database.host + ":" + config.database.port + "/" + config.database.name + " ###")
    var rethinkDB = require("@tutor/rethinkdb-database")(config);
    return rethinkDB.then(function(DB){
      restAPI = require("./rest")(DB);
      configureServer(restAPI, DB, function(user, pw){
        // in dev mode, if somebody logs in
        //  1.  look if the user exists, if yes grant access
        //  2.  if the user does not exists create new user
        return DB.Users.exists(user).then(function(exists){
          if(!exists){
            return DB.Users.create(
              {
                id: user,
                matrikel: "12345670",
                name: "Karl Günther",
                pseudonym: "Nameless Nobody"
              }
            ).then(function(){ return true; });
          } else {
            return true;
          }
        });
      });
      return restAPI;
    });

  }
}
