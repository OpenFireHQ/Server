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

  # User to perform object flattening algorithm
  # and optimize primitive types and objects ;)
  optimizeAndFlatten = (attrs) ->

    { path, obj, cb, tabs, update, deletedPath } = attrs
    log "optimizeAndFlatten, obj: ", obj

    tabs = "" if !tabs?
    deletedPath = no if !deletedPath?

    parts = path.split("/")
    previous = parts.slice(0, parts.length -  1).join("/")
    previous2 = parts.slice(0, parts.length -  2).join("/")

    if not update and not deletedPath
      log "Deleting previous parent object path: ", path
      db.deletePath path

    if obj isnt null and typeof obj is 'object'
      # For setting Objects
      bulk = {}
      for k of obj
        if typeof obj[k] isnt 'object'
          bulk[k] = obj[k]
        else
          optimizeAndFlatten(
            path: path + "/" + k,
            obj: obj[k],
            tabs: tabs + "  "
            cb: cb
            update: update
            deletedPath: yes
          )

        if update
          db.update(
            obj: bulk
            path: path
          )
        else
          db.set(
            obj: bulk
            path: path
          )
    else
      # For primitive types (string, int...)
      lastKey = parts.slice(parts.length -  1, parts.length).join("/")
      newObj = {}
      newObj[lastKey] = obj

      if update
        db.update(
          obj: newObj
          path: previous
        )
      else
        db.set(
          obj: newObj
          path: previous
        )

      cb() if cb?

    return null

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

      else if type is 'update'
        { obj, path } = data

        optimizeAndFlatten(
          path: path
          obj: obj
          update: yes
        )

      else if type is 'set'
        { obj, path } = data

        optimizeAndFlatten(
          path: path
          obj: obj
          update: no
        )

      return

    return
