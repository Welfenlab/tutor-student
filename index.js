var config = require("cson").load("config.cson");
var TutorServer = require("@tutor/server");
var MemDB = require("@tutor/memory-database")(config);
//var rethinkDB = require("@tutor/rethinkdb-database")(config);
var express = require("express");

restAPI = require("./src/rest")(MemDB);
//restAPI = require("./src/rest")(rethinkDB);


config.modules = [
  require("@tutor/dummy-auth")(MemDB.Student.userExists), // This must be array element #0
  require('@tutor/share-ace-rethinkdb'),
];
config.log = console;

if(config.development){
  config.modules.push(function(app, config){
    app.use(express.static('./build'));
    // enable cors for development
    app.use(function(req, res, next) {
      res.header("Access-Control-Allow-Origin", "*");
      res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
      next();
    });
    app.use(require('morgan')('dev'));
  });
}

// create a server
var server = TutorServer(config);

// register rest API
restAPI.forEach(function(rest){
  server.createRestCall(rest);
});

// start the server
server.start();
