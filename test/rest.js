
chai = require("chai");
chai.should();

var config = require("cson").load("./test/fixtures/config.cson");
var request = require("request");
var TutorServer = require("@tutor/server");


var memDB = require("@tutor/memory-database")();
memDB.Restore("./test/fixtures/db.json");
restAPI = require("../src/rest")(memDB);
var server = TutorServer(config);

// register rest API
restAPI.forEach(function(rest){
  server.createRestCall(rest);
});
server.start()
var doRequest = function(method, path, fn){
  request({
    url: "http://"+config.domainname+":"+config.developmentPort+"/api"+path,
    method: method, //Specify the method
    headers: { //We can define headers too
        'Content-Type': 'MyContentType',
        'Custom-Header': 'Custom Value'
    }
  }, function(err, res, body){
    fn(err, res, JSON.parse(body));
  });
}

describe("Student REST API", function(){
  it("should return all exercises",function(done){
    doRequest("GET","/exercises",
      function(err, res, body){
        body.should.have.length(2);
        res.statusCode.should.equal(200);
        done();
      });
  });
  it("list of exercises should only contain task ids",function(done){
    doRequest("GET","/exercises",
      function(err, res, body){
        body.forEach(function(ex){
          ex.tasks.forEach(function(t){
            (typeof(t)).should.equal("string");
          });
        });
        done();
      });
  });
});
