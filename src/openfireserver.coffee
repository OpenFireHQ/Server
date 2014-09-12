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
  DataParser = require "./dataparser"

  bigDict = new BigDict(db)
  clientNotifier = new ClientNotifier(bigDict)
  validator = new Validator(db, bigDict)
  validate = validator.validate
  dataParser = new DataParser(bigDict, clientNotifier, validator)

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
  primus.on "disconnection", (spark) ->
    bigDict.get(metaPath + "/commandQueue/afterDisconnect/" + spark.id, (obj) =>
      log "A client just disconnected, possible disconnection queue: " + displayObject obj
      commands = obj?['afterDisconnect']?[spark.id]
      if commands
        for k of commands
          log "Running Command: ", commands[k]
          { action, path, obj } = commands[k]
          obj = JSON.parse obj
          data =
            action: action
            path: path
            obj: obj

          skipValidation = validator.accessesMeta path
          dataParser.parse(spark, data, skipValidation)

        # After the loop, delete all commands for this connected id
        log "Commands fired, now deleting queue"
        deleteObj = { }
        deleteObj[spark.id] = null
        bigDict.update(
          path: metaPath + "/commandQueue/afterDisconnect"
          obj: deleteObj
        )

    , omitParentObject: yes)

  primus.on "connection", (spark) ->
    log "We have a caller!"
    log "connection was made from", spark.address
    log "connection id", spark.id

    spark.on "data", (data) ->
      dataParser.parse(spark, data)

  exports.bigDict = bigDict
  return attrs
