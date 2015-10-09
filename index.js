
var config;
if(process.argv.length == 2){
  config = require("cson").load("config.cson");
} else {
  config = require("cson").load(process.argv[2]);
}
var TutorServer = require("@tutor/server");
var express = require("express");


config.modules = []
var restAPI = null;

var startServer = function(data){
  // load logging modules
  require("./src/logging")(config);

  // additional server modules for all environments
  config.modules = config.modules.concat([
    require('@tutor/share-ace-rethinkdb')(data.db),
  ]);

  // create the server
  var server = TutorServer(config);

  // register rest API
  data.api.forEach(function(rest){
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
