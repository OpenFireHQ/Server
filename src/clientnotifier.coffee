class ClientNotifier

  pathEditor = require 'path'

  constructor: (@bigDict) ->

  sub: (spark, path, type) ->
    room = type + ":" + path
    spark.join room

    if type is 'value'
      @bigDict.get(path, (obj) =>
        @notify(spark, {
          type: type
          path: path
          obj: obj
          name: null
        }, no, yes)
      , omitParentObject: yes)

      obj = {}
      obj[spark.id] = true

      listenerPath = metaPath + "/listeners/value" + path #.replace(/\//gi, '_')

      @bigDict.update(
        path: listenerPath
        obj: obj
      )

      obj[spark.id] = null

      @bigDict.update(
        path: metaPath + "/commandQueue/afterDisconnect/" + spark.id + "/update" + listenerPath.replace(/\//gi, '_')
        obj:
          action: 'update'
          path: listenerPath
          obj: JSON.stringify(obj)

        callback: ->

      )

    else if type is 'child' or type is 'remote_child'
      @bigDict.get(path, (obj) ->
        for k of obj
          for k2 of obj[k]
            spark.write(action: 'data', path: path, type: type, obj: obj[k][k2], name: k2)
      )

  notify: (spark, attrs, supportRemote = yes, justMe = no) ->
    { type, path, obj, name } = attrs
    room = type + ":" + path
    note = action: 'data', path: path, type: type, obj: obj, name: name

    if justMe
      log "Notifying a single client with data: #{displayObject note}"
      # justMe overrides remote_ behaviour
      spark.write note
    else
      log "Notifying all clients in room #{room} with data: #{displayObject note}"
      spark.room(room).write note

      if supportRemote
        # Create one for remote notes only as well
        note.type = "remote_" + note.type
        room = note.type + ":" + path
        spark.room(room).except(spark.id).write note

module.exports = ClientNotifier
