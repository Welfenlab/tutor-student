
chai = require("chai");
chai.should();

var config = require("cson").load("./test/fixtures/config.cson");
var request = require("request");
var TutorServer = require("@tutor/server");


var memDB = require("@tutor/memory-database")();
var restoreDB = function(){
  memDB.Restore("./test/fixtures/db.json");
};
var restAPI = require("../src/rest")(memDB);
config.modules = [function(app,config){
  app.use(function(req,res,next){ req.session = {uid:"ABC-DEF"}; next() });
}];
config.log = {error:function(){},log:function(){}};
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
    var parsed = null;
    try{
      parsed = JSON.parse(body);
      fn(err,res,parsed);
    } catch(e){
      console.log("Error parsing body\n"+body);
      console.log(e);
      fn(e);
    }
  });
}

beforeEach(function(){
  restoreDB();
})

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

  it("a single exercise should contain tasks", function(done){
    doRequest("GET", "/exercises/ee256059-9d92-4774-9db2-456378e04586",
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
        if(err) err.should.be.null;
        res.statusCode.should.equal(204);
        doRequest("GET", "/user/pseudonym",
          function(err, res, body){
            if(err) err.should.be.null;
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
  it("should be able to create a group with others", function(done){
    doRequest("POST", "/group", {users:["Lonely Gates","Tiny Knuth"]},
      function(err,res,body){
        (err == null).should.be.true;
        res.statusCode.should.equal(200);
        body.users.should.deep.equal(["Lazy Dijkstra"]);
        body.pendingUsers.should.deep.equal(["Lonely Gates","Tiny Knuth"]);
        done();
      }
    );
  });
  it("should be able to list pending groups", function(done){
    doRequest("GET", "/group/pending",
      function(err, res, body){
        (err == null).should.be.true;
        res.statusCode.should.equal(200);
        Array.isArray(body).should.be.true;
        body.should.have.length(1);
        done();
    });
  });
  it("should be able to join a pending group", function(done){
    doRequest("POST", "/group/join", {group: "fd8c6b08-572d-11e5-9824-685b35b5d746"},
      function(err, res, body){
        (err == null).should.be.true;
        res.statusCode.should.equal(200);
        body.id.should.equal("fd8c6b08-572d-11e5-9824-685b35b5d746");
        // ensure persistence
        doRequest("GET", "/group",
          function(err, res, body){
            (err == null).should.be.true;
            body.id.should.equal("fd8c6b08-572d-11e5-9824-685b35b5d746");
            done();
        });
    });
  });
  it("should not be able to join any group without an invitation", function(done){
    doSimpleRequest("POST", "/group/join", {group: "fd8c6b07-572d-11e5-9824-685b35b5d746"},
      function(err, res, body){
        res.statusCode.should.equal(401);
        //(err == null).should.be.false;
        done();
    });
  });
  it("should be able to reject an invitation", function(done){
    doSimpleRequest("POST", "/group/reject", {group: "fd8c6b08-572d-11e5-9824-685b35b5d746"},
      function(err, res, body){
        (err == null).should.be.true;
        res.statusCode.should.equal(204);
        // ensure persistence
        doRequest("GET", "/group/pending",
          function(err, res, body){
            (err == null).should.be.true;
            body.should.have.length(0);
            done();
        });
    });
  });

  it("should be possible to get the solution for an exercise", function(done){
    doRequest("GET", "/solution/ee256059-9d92-4774-9db2-456378e04586",
      function(err, res, body){
        (err == null).should.be.true;
        res.statusCode.should.equal(200);
        body.solution.should.have.length(3);
        done();
    });
  });

  it("should be possible to store a solution", function(done){
    doSimpleRequest("PUT", "/solution",
      {exercise: "f31ad341-9d92-4774-9db2-456378e04586", solution: ["a","b","c"]},
      function(err, res, body){
        (err == null).should.be.true;
        res.statusCode.should.equal(204);
        // ensure persistence
        doRequest("GET", "/solution/f31ad341-9d92-4774-9db2-456378e04586",
          function(err, res, body){
            (err == null).should.be.true;
            body.solution.should.deep.equal(["a","b","c"]);
            done();
        });
    });
  });
});
