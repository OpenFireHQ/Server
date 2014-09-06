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

  getClosestObjectPathForValue: (path, callback, _meta = null) ->
    @db.get(path, (obj) =>
      if obj is null
        # Either deleted or we have to get a step back so we can fetch the object
        parts = path.split("/")
        previous = parts.slice(0, parts.length -  1).join("/")
        lastPath = parts.slice(parts.length -  1, parts.length).join("/")

        if not _meta?.traversedBackOnce?
          @getClosestObjectPathForValue(previous, callback, { traversedBackOnce: yes })
        else
          callback null
      else
        # Callback immediatly
        callback(path)
    )

  getClosestObject: (path, callback, _meta = null) ->
    log "BigDict, getClosestObjecting: ", path
    @db.get(path, (obj) =>
      log "Value: " + displayObject(obj)
      if obj is null
        # Either deleted or we have to get a step back so we can fetch the object
        parts = path.split("/")
        previous = parts.slice(0, parts.length -  1).join("/")
        lastPath = parts.slice(parts.length -  1, parts.length).join("/")

        if not _meta?.traversedBackOnce?
          @get(previous, callback, { traversedBackOnce: yes })
        else
          callback(null)
      else
        # Callback immediatly
        callback(obj)
    )

  get: (path, callback, _meta = { callback: {} }) ->
    log "BigDict, getting: ", path if not _meta.traversedBackOnce?
    @db.get(path, (obj) =>
      if obj is null
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
        if _meta?.objectName?
          obj = obj[_meta.objectName] or null
          log "Value: " + displayObject(obj)
          callback(obj, _meta.callback)
        else
          log "Value: " + displayObject(obj)
          callback(obj, _meta.callback)
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

  childAddedOrRemovedNotification: (attrs) ->
    log "childAddedOrRemovedNotification with attrs:#{displayObject attrs}"
    { path, objectToSend, pathToSend, notifications } = attrs
    @get(path, (currentObj) ->
      if currentObj?
        #this object already exists at this path, child_changed or removed
        notifications(
          type: 'child_removed'
          path: pathToSend
          obj: objectToSend
        ) if notifications?
      else
        #this object does not yet exists, child_added
        notifications(
          type: 'child_added'
          path: pathToSend
          obj: objectToSend
        ) if notifications?
    )

  edit: (attrs) ->

    { path, obj, callback, update, deletedPath, notifications } = attrs

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
            notifications: notifications
            deletedPath: deletedPath
          )
        else
          bulk[k] = obj[k]
          @childAddedOrRemovedNotification( notifications: notifications, path: path, pathToSend: previous, objectToSend: obj[k] )

      if !isEmpty(bulk)
        @childAddedOrRemovedNotification( notifications: notifications, path: path, pathToSend: previous, objectToSend: obj )

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
