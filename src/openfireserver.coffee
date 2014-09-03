http = require("http")
Primus = require('primus')
Rooms = require('primus-rooms')
BigDict = require('./bigdict')
require "./global"

exports.start = (attrs) ->
  server = http.createServer((req, res) ->

  ).listen 5454, "127.0.0.1"

  Db = require("./dbs/#{attrs.db}")
  db = new Db()
  bigDict = new BigDict(db)

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

  primus.save(__dirname + '/realtime_engine.js')
  primus.on "connection", (spark) ->
    log "We have a caller!"
    log "connection was made from", spark.address
    log "connection id", spark.id

    spark.on "data", (data) ->
      log "received data from the client", data

      { action } = data

      if action is 'unsub'
        { path } = data
        spark.leave path, ->
          return

      else if action is 'sub'
        trySub data

      else if action is 'update'
        { obj, path } = data

        bigDict.update(path, obj, ->

        )

      else if action is 'set'
        { obj, path } = data

        bigDict.set(path, obj, ->
          
        )

      return

    return
