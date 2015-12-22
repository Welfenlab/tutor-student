
var express = require("express");

// initialize the production environment
module.exports = function(config){
  console.log("production environment");
  console.log("... waiting 10s for RethinkDB");
  
  config.domainname = process.env.TUTOR_DOMAIN_NAME
  config.database.host = process.env.RETHINKDB_PORT_28015_TCP_ADDR;
  config.database.port = parseInt(process.env.RETHINKDB_PORT_28015_TCP_PORT);
  config.session = config.session | {}
  config.session.secret = process.env.TUTOR_SESSION_SECRET
  config.saml.privateKey = process.env.TUTOR_SAML_KEY;
  config.saml.certificate = process.env.TUTOR_SAML_CERT
  config.saml.idpLoginUrl = process.env.TUTOR_IDP_LOGIN_URL
  config.saml.idpCertificate = process.env.TUTOR_IDP_CERT
  
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
      if(!process.env.UNSAFE_LOGIN){
        config.modules.push(require("@tutor/saml")(DB.Connection, DB.Rethinkdb, 
            DB.Users.create, DB.Users.exists,
            function(){return Promise.resolve()} ));
      } else {
        var userLogin = function(user, pw){
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
        }
        
        config.modules.push(require("@tutor/auth")(con, DB.Rethinkdb, userlogin));
      }
      config.modules.push(function(app, config){
        app.use(express.static('./build'));
      });
      return {api: restAPI, db: DB};
    });
  });
}
