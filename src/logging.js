
// initialize the logging
module.exports = function(config){
  var bunyan = require("bunyan");

  config.logger = bunyan;
  config.log = console;
}
