basedb = require "./basedb"
class Memory extends basedb

  showMem = ->
    log "Memory is now: \n" + displayObject(db)

  # In-memory storage object
  db = {}

  delete: (path) ->
    delete db[path]

  deletePath: (thisPath, callback) ->
    # Delete child objects under this path
    for path of db
      if path is thisPath or path.startsWith thisPath + "/"
        @delete path

    callback() if callback?

  getPathNamesStartingWithPath: (thisPath, callback) ->
    result = []
    for path of db
      if path is thisPath or path.startsWith thisPath + "/"
        result.push(path)

    if result.length is 0
      callback null
    else
      callback result

  getStartingWithPath: (thisPath, callback) ->
    result = []
    for path of db
      if path is thisPath or path.startsWith thisPath + "/"
        result.push(path: path, obj: db[path])

    if result.length is 0
      callback null
    else
      callback result

  get: (path, callback) ->
    obj = db[path]
    if obj?
      # Object exists, return
      callback(obj)
    else
      callback(null)

  set: (obj, callback) ->

    # Everything in obj.obj should be a primitive type
    # This is done by the flatenning algorithm on the Server-side

    objToSetIn = db[obj.path]
    if obj.obj is null
      delete db[obj.path]
    else
      db[obj.path] = {} if not db[obj.path]?
      objToSetIn = db[obj.path]
      for k of obj.obj
        if obj.obj[k] == null
          delete objToSetIn[k]
        else
          objToSetIn[k] = obj.obj[k]

    if isEmpty objToSetIn
      delete db[obj.path]

    showMem()
    callback() if callback

module.exports = Memory
