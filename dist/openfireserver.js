(function() {
  var BaseDB, Memory, Primus, basedb, http, server,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = BaseDB = (function() {
    function BaseDB() {}

    return BaseDB;

  })();

  basedb = require("./basedb");

  module.exports = Memory = (function(_super) {
    var db;

    __extends(Memory, _super);

    function Memory() {
      return Memory.__super__.constructor.apply(this, arguments);
    }

    db = {};

    Memory.prototype.createObject = function(obj, callback) {
      var id;
      id = obj.id || Math.round(Math.random() * 1000) + "";
      if (obj.id) {
        delete obj.id;
      }
      return db[id] = obj;
    };

    return Memory;

  })(basedb);

  http = require("http");

  Primus = require('primus');

  exports.start = function() {
    var primus, server;
    server = http.createServer(function(req, res) {}).listen(5454, "127.0.0.1");
    return primus = new Primus(server, {
      pathname: '/realtime',
      parser: 'JSON'
    });
  };

  server = require("./openfireserver");

  server.start({
    db: "memory"
  });

  console.log("Server running at http://127.0.0.1:5454/");

  console.log('Connect to this DB using the OpenFire SDK: db = new OpenFire("http://127.0.0.1/db")');

}).call(this);
