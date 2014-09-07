http = require("http")
Primus = require('primus')
Rooms = require('primus-rooms')
BigDict = require('./bigdict')
ClientNotifier = require './clientnotifier'
Validator = require './validator'
extend = require('node.extend')

require "./global"
defaults =
  port: 5454
  host: "0.0.0.0"
  db: "memory"
  logging: no

exports.start = (attrs) ->
  attrs = extend(defaults, attrs)
  if !attrs.logging
    global.log = (msg) ->
      # To the bitbucket!
  server = http.createServer((req, res) ->

  ).listen attrs.port, attrs.host

  Db = require("./dbs/#{attrs.db}")
  db = new Db()
  bigDict = new BigDict(db)
  clientNotifier = new ClientNotifier(bigDict)
  validate = new Validator(db, bigDict)

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
        { path, type } = data
        spark.leave type + ":" + path

      else if action is 'sub'
        { path, type } = data
        clientNotifier.sub(spark, path, type)

      else if action is 'update'
        { obj, path } = data
        validate data, ->
          bigDict.handleNotifications(
            path: path
            obj: obj
            callback: (note) ->
              clientNotifier.notify(spark, note)
          )
          bigDict.update(
            path: path
            obj: obj
            callback: ->

          )

      else if action is 'set'
        { obj, path } = data
        validate data, ->
          bigDict.handleNotifications(
            path: path
            obj: obj
            callback: (note) ->
              clientNotifier.notify(spark, note)
          )
          bigDict.set(
            path: path
            obj: obj
            callback: ->

          )

  return attrs
