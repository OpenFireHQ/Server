class DataParser

  constructor: (@bigDict, @clientNotifier, @validate) ->

  parse: (spark, data) ->
    bigDict = @bigDict
    clientNotifier = @clientNotifier
    validate = @validate

    log "received data from the client", data

    { action } = data

    if action is 'unsub'
      { path, type } = data
      spark.leave type + ":" + path

    else if action is 'sub'
      { path, type } = data
      validate data, ->
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

    else if action is 'afterDisconnect:update'
      { obj, path } = data
      #No validation here, because nothing really happens, and validation can change over time
      #validation will happen at the moment the commands will be executed
      bigDict.set(
        path: metaPath + "/commandQueue/afterDisconnect/" + spark.id + "/update" + path.replace(/\//gi, '_')
        obj:
          action: 'update'
          path: path
          obj: JSON.stringify(obj)

        callback: ->

      )

    else if action is 'afterDisconnect:set'
      { obj, path } = data
      #No validation here, because nothing really happens, and validation can change over time
      #validation will happen at the moment the commands will be executed
      bigDict.set(
        path: metaPath + "/commandQueue/afterDisconnect/" + spark.id + "/set" + path.replace(/\//gi, '_')
        obj:
          action: 'set'
          path: path
          obj: JSON.stringify(obj)

        callback: ->

      )

module.exports = DataParser
