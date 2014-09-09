# BigDict
# =======
# Used to perform object flattening algorithm
# and optimize primitive types and objects ;)

class BigDict

  constructor: (@db) ->

  delete: (path, callback) ->
    log "BigDict, deleting: ", path
    @get(path, (obj) =>
      if obj isnt null
        if typeof obj is 'object'
          @db.deletePath path, ->
            callback() if callback?
        else
          parts = path.split("/")
          previous = parts.slice(0, parts.length -  1).join("/")
          lastPath = parts.slice(parts.length -  1, parts.length).join("/")

          deleteObj = {}
          deleteObj[lastPath] = null

          @db.set(
            obj: deleteObj
            path: previous
          , ->
            callback() if callback?
          )
      else
        callback() if callback?
    )

  get: (path, callback, _meta = { callback: {} }) ->
    log "BigDict, getting: ", path if not _meta.traversedBackOnce?
    @db.getStartingWithPath(path, (objs) =>
      log "low level objs: ", displayObject objs
      if objs is null
        # Either deleted or we have to get a step back so we can fetch the object
        parts = path.split("/")
        previous = parts.slice(0, parts.length -  1).join("/")
        lastPath = parts.slice(parts.length -  1, parts.length).join("/")

        if not _meta.traversedBackOnce?
          _meta.objectName = lastPath
          _meta.traversedBackOnce = yes
          @get(previous, callback, _meta)
        else
          log "Value: " + displayObject(obj)
          callback(null, _meta.callback)
      else
        # Callback immediatly
        obj = @normalizeData(objs)
        log "Get result: ", displayObject obj
        if _meta.objectName?
          callback obj[_meta.objectName] or null
        else
          callback obj
    )

  set: (attrs) ->

    { path, obj, callback, notifications } = attrs

    @edit(
      notifications: notifications
      path: path
      obj: obj
      callback: callback
      update: no
    )

  update: (attrs) ->

    { path, obj, callback, notifications } = attrs

    @edit(
      notifications: notifications
      path: path
      obj: obj
      callback: callback
      update: yes
    )

  normalizeData: (dataArray) ->
    result = {}
    for d in dataArray
      { path, obj } = d
      parts = path.split("/").filter((el) ->
        el.length isnt 0
      )
      objToWorkWith = result
      lastPath = parts.slice(parts.length -  1, parts.length).join("/")
      firstPath = parts[0]
      for i in [0..parts.length - 1]
        part = parts[i]
        #log "normalizeData -> Going over part: ", part
        if i > 0
          if !objToWorkWith[part]?
            objToWorkWith[part] = {}

          objToWorkWith = objToWorkWith[part]

      for k of obj
        objToWorkWith[k] = obj[k]

    return result

  handleNotifications: (attrs) ->

    { callback, path, obj } = attrs

    log "handleNotifications: ", path

    parts = path.split("/")
    firstPath = parts.slice(0, 2).join("/")
    loopKeysAsPaths = (newData, oldData, _path = firstPath) =>
      if typeof newData is 'object'
        for k of newData
          __path = _path + "/" + k
          if typeof newData[k] is 'object'
            loopKeysAsPaths(newData[k], oldData?[k], __path)

          if oldData?[k]
            if newData[k] is null
              # Removed
              callback(
                type: 'child_removed'
                path: _path
                name: k
                obj: oldData[k]
              ) if callback?
            else
              # edited
              callback(
                type: 'child_changed'
                path: _path
                name: k
                obj: newData[k]
              ) if callback?
          else
            callback(
              type: 'child_added'
              path: _path
              name: k
              obj: newData[k]
            ) if callback?

    newData = @normalizeData [{path: path, obj: obj}]
    @get(path, (oldData) ->
      #log "loopKeysAsPaths: \nNew: #{displayObject  newData}\n Old: #{displayObject oldData}"
      loopKeysAsPaths(newData, oldData)
    )


  edit: (attrs) ->

    { path, obj, callback, update, deletedPath } = attrs

    cbCount = 0
    cbCountTick = ->
      cbCount--
      if cbCount is 0
        callback() if callback?

    parts = path.split("/")
    previous = parts.slice(0, parts.length -  1).join("/")
    previous2 = parts.slice(0, parts.length -  2).join("/")
    lastPath = parts.slice(parts.length -  1, parts.length).join("/")

    if not update and not deletedPath
      log "Deleting previous parent object path: ", path
      @db.deletePath path

    # Before writing down a value, check if there is a primitive set
    @deletePrimitiveTypesUnderPathComponents path

    if obj isnt null and typeof obj is 'object'
      # For setting Objects
      bulk = {}
      for k of obj
        if obj[k] != null and typeof obj[k] is 'object'
          cbCount++
          @edit(
            path: "#{path}/#{k}"
            obj: obj[k]
            callback: cbCountTick
            update: update
            deletedPath: deletedPath
          )
        else
          bulk[k] = obj[k]

      if !isEmpty(bulk)

        @db.set(
          obj: bulk
          path: path
        , ->
          cbCountTick()
        )

  deletePrimitiveTypesUnderPathComponents: (path, callback) ->
    log "deletePrimitiveTypesUnderPathComponents: ", path
    @get(path, (obj) =>
      if obj isnt null
        if typeof obj isnt 'object'
          # Primitive type, needs to be removed
          @delete(path)

      parts = path.split("/")
      previous = parts.slice(0, parts.length -  1).join("/")

      if previous.length > 0
        @deletePrimitiveTypesUnderPathComponents(previous, callback)
      else
        callback() if callback?
    )

module.exports = BigDict
