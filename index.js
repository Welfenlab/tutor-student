var config = require("cson").load("config.cson");
var TutorServer = require("@tutor/server");
var express = require("express");


config.modules = []
var restAPI = null;

// initialize the appropiate environment
if(process.env.NODE_ENV != "production"){
  restAPI = require("./src/development")(config)
} else {
  restAPI = require("./src/production")(config)
}

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
