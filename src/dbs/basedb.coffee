module.exports = class BaseDB

  backTraverse: (path, cb) ->

    db.get(path, (obj) ->

      #if obj is null
    )


    tryTraverse = (data) ->
      { type, path } = data
      log "Trying to subscribe to ", data
      db.get(path, (obj) ->
        if obj is null
          # try if it's in a parent object
          parts = path.split("/")
          previous = parts.slice(0, parts.length -  1).join("/")

          trySub(
            type: type
            path: previous
          )
        else
          spark.write(
            path: path
            obj: obj
            type: type
            action: 'data'
          )
      )
