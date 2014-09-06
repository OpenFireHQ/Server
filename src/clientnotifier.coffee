class ClientNotifier

  constructor: (@bigDict) ->

  sub: (spark, path, type) ->
    room = type + ":" + path
    spark.join room

    if type is 'value'
      @bigDict.get(path, (obj) ->
        spark.write(action: 'data', path: path, type: type, obj: obj)
      )

  notify: (spark, attrs) ->
    { type, path, obj } = attrs
    room = type + ":" + path
    note = action: 'data', path: path, type: type, obj: obj
    log "Notifying all clients in room #{room} with data: #{displayObject note}"
    spark.room(room).write note


module.exports = ClientNotifier
