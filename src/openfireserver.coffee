http = require("http")
Primus = require('primus')
Rooms = require('primus-rooms')
require "./global"

exports.start = (attrs) ->
  server = http.createServer((req, res) ->

  ).listen 5454, "127.0.0.1"

  Db = require("./dbs/#{attrs.db}")
  db = new Db()

  setObject = (path, obj, cb, tabs = "") ->
    if typeof obj == 'object'
      for k of obj
        setObject(path + "/" + k, obj[k], cb, tabs + "  ")
    else
      parts = path.split("/")
      previous = parts.slice(0, parts.length -  1).join("/")
      lastKey = parts.slice(parts.length -  1, parts.length).join("/")
      newObj = {}
      newObj[lastKey] = obj

      log tabs + "Primitive type value belonging to " + previous

      db.update(
        path: previous
        obj: newObj
      cb)

    return null

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
        { obj, path } = data
        log "Setting to #{path}"

        # Delete previous path to make sure our transition to a objects goes well
        parts = path.split("/")
        previous = parts.slice(0, parts.length -  1).join("/")
        db.delete previous

        setObject(path, obj, ->
          spark.room(path).write()
        )

      return

    return
