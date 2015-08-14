
var config = require("cson").load("config.cson");
var TutorServer = require("@tutor/server");
var MemDB = require("@tutor/memory-database")(config);
var express = require("express");

restAPI = require("./src/rest")(MemDB);

config.modules = [
  require("@tutor/dummy-auth"),
];

if(config.development){
  config.modules.push(function(app, config){
    app.use(express.static('./build'));
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
