
chai = require("chai");
chai.should();

var config = require("cson").load("./test/fixtures/config.cson");
var request = require("request");
var TutorServer = require("@tutor/server");


var memDB = require("@tutor/memory-database")();
memDB.Restore("./test/fixtures/db.json");
restAPI = require("../src/rest")(memDB);
config.modules = [function(app,config){
  app.use(function(req,res,next){ req.session = {uid:"ABC-DEF"}; next() });
}];
var server = TutorServer(config);

// register rest API
restAPI.forEach(function(rest){
  server.createRestCall(rest);
});
server.start()
var doSimpleRequest = function(method, path, data, fn){
  request({
    url: "http://"+config.domainname+":"+config.developmentPort+"/api"+path,
    method: method, //Specify the method
    form: data,
    headers: { //We can define headers too
        'Content-Type': 'MyContentType',
        'Custom-Header': 'Custom Value'
    }
  }, fn);
}
var doRequest = function(method,path,data,fn){
  if(typeof(data) == "function"){
    fn = data;
    data = null;
  }
  doSimpleRequest(method,path,data,function(err,res,body){
    fn(err,res,JSON.parse(body));
  });
}

describe("Student REST API", function(){
  it("should return all exercises",function(done){
    doRequest("GET","/exercises",
      function(err, res, body){
        (err == null).should.be.true;
        body.should.have.length(2);
        res.statusCode.should.equal(200);
        done();
      });
  });
  it("list of exercises should only contain task ids",function(done){
    doRequest("GET","/exercises",
      function(err, res, body){
        (err == null).should.be.true;
        body.forEach(function(ex){
          ex.tasks.forEach(function(t){
            (typeof(t)).should.equal("string");
          });
        });
        done();
      });
  });

  it("the detailed list should contain tasks", function(done){
    doRequest("GET", "/exercises/detailed/ee256059-9d92-4774-9db2-456378e04586",
      function(err, res, body){
        (err == null).should.be.true;
        body.tasks.forEach(function(t){
          (typeof(t)).should.equal("object");
        });
        res.statusCode.should.equal(200);
        done();
    });
  });

  it("should be possible to get a list of all pseudonyms", function(done){
    doRequest("GET", "/pseudonyms",
      function(err, res, body){
        (err == null).should.be.true;
        (Array.isArray(body)).should.be.true;
        body.should.have.length(3);
        res.statusCode.should.equal(200);
        done();
    });
  });

  it("should be able to query user data", function(done){
    doRequest("GET", "/user",
      function(err, res, body){
        (err == null).should.be.true;
        body.id.should.equal("ABC-DEF");
        res.statusCode.should.equal(200);
        done();
      }
    );
  });
  it("should be able to query ones pseudonym", function(done){
    doRequest("GET", "/user/pseudonym",
      function(err, res, body){
        (err == null).should.be.true;
        body.should.equal("Lazy Dijkstra");
        res.statusCode.should.equal(200);
        done()
      }
    );
  });

  it("should be able to change ones pseudonym", function(done){
    doSimpleRequest("PUT", "/user/pseudonym", {pseudonym: "NEW PSEUDO"},
      function(err, res, body){
        (err == null).should.be.true;
        res.statusCode.should.equal(204);
        doRequest("GET", "/user/pseudonym",
          function(err, res, body){
            (err == null).should.be.true;
            body.should.equal("NEW PSEUDO");
            done();
          }
        );
      }
    )
  });

  it("should be able to get group information", function(done){
    doRequest("GET", "/group",
      function(err, res, body){
        (err == null).should.be.true;
        (typeof(body)).should.equal("object");
        (Array.isArray(body)).should.be.false;
        body.users.should.have.length(1);
        done();
      }
    );
  });
  it("should be able to leave a group", function(done){
    doRequest("DELETE", "/group",
      function(err, res, body){
        (err == null).should.be.true;
        done();
      }
    );
  });
});
