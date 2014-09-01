http = require("http")
Primus = require('primus')
Rooms = require('primus-rooms')
require "./global"

exports.start = (attrs) ->
  server = http.createServer((req, res) ->

  ).listen 5454, "127.0.0.1"

  Db = require("./dbs/#{attrs.db}")
  db = new Db()

  primus = new Primus(server, {
    global: 'OFRealtimeEngine'
    pathname: '/realtime'
    parser: 'JSON'
    transformer: 'engine.io'
  })
  primus.use('rooms', Rooms)

  primus.on "error", error = (err) ->
    console.error "Something horrible has happened", err.stack
    return

  #primus.save(__dirname + '/primus.js')
  primus.on "connection", (spark) ->
    log "We have a caller!"
    log "connection has the following headers", spark.headers
    log "connection was made from", spark.address
    log "connection id", spark.id

    spark.on "data", (data) ->
      log "received data from the client", data

      { type } = data

      if type is 'unsub'
        { path } = data
        spark.leave path, ->
          return

      else if type is 'sub'
        { path } = data
        spark.join path, ->
          return

      else if type is 'set'
        # First check if there is already something at this path
        { obj, path } = data
        log "Setting to #{path}"
        db.set(
          path: path
          obj: obj
        )

      return

    spark.write "Hello world"
    return
