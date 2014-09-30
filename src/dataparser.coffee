class DataParser

  constructor: (@bigDict, @clientNotifier, @validator) ->

  parse: (spark, data, skipValidation = no) ->
    bigDict = @bigDict
    clientNotifier = @clientNotifier
    validator = @validator
    accessesMeta = @validator.accessesMeta

    log "received data from the client", data

    { action } = data

    if action is 'unsub'
      { path, type } = data
      spark.leave type + ":" + path

    else if action is 'sub'
      { path, type } = data
      validator.validate data, skipValidation, ->
        clientNotifier.sub(spark, path, type)

    else if action is 'update'
      { obj, path } = data
      validator.validate data, skipValidation, ->
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
            log "Update #{path} finished"
            bigDict.triggerValueNotifications(path: path, callback: (note) ->
              clientNotifier.notify(spark, note)
            )
        )

    else if action is 'set'
      { obj, path } = data
      validator.validate data, skipValidation, ->
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
            bigDict.triggerValueNotifications(path: path, callback: (note) ->
              clientNotifier.notify(spark, note)
            )
        )

    else if action is 'afterDisconnect:update'
      { obj, path } = data

      return if accessesMeta path

      #No validation here, because nothing really happens, and validation can change over time
      #validation will happen at the moment the commands will be executed
      bigDict.update(
        path: metaPath + "/commandQueue/afterDisconnect/" + spark.id + "/update" + path.replace(/\//gi, '_')
        obj:
          action: 'update'
          path: path
          obj: JSON.stringify(obj)

        callback: ->

      )

    else if action is 'afterDisconnect:set'
      { obj, path } = data

      return if accessesMeta path

      #No validation here, because nothing really happens, and validation can change over time
      #validation will happen at the moment the commands will be executed
      bigDict.update(
        path: metaPath + "/commandQueue/afterDisconnect/" + spark.id + "/set" + path.replace(/\//gi, '_')
        obj:
          action: 'set'
          path: path
          obj: JSON.stringify(obj)

        callback: ->

      )

module.exports = DataParser
