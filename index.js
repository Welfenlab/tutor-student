var config = require("cson").load("config.cson");
var TutorServer = require("@tutor/server");
var express = require("express");


config.modules = []
var restAPI = null;

var startServer = function(restAPI){
  // load logging modules
  require("./src/logging")(config);

  // additional server modules for all environments
  config.modules = config.modules.concat([
    require('@tutor/share-ace-rethinkdb'),
  ]);

  // create the server
  var server = TutorServer(config);

  // register rest API
  restAPI.forEach(function(rest){
    server.createRestCall(rest);
  });

  // start the server
  server.start();
}

var starter;
// initialize the appropiate environment
if(process.env.NODE_ENV != "production"){
  starter = require("./src/development")(config);
} else {
  starter = require("./src/production")(config);
}

starter.then(startServer).catch(function(e){
  console.error(e.stack);
});
