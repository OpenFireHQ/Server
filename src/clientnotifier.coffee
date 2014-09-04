class ClientNotifier

  constructor: (@bigDict) ->

  sub: (spark, path, type) ->
    room = type + ":" + path
    spark.join room

    @bigDict.get(path, (obj) ->
      if type is 'value'
        spark.write(action: 'data', path: path, type: type, obj: obj)
    )


module.exports = ClientNotifier
