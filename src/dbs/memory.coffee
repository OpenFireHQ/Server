basedb = require "./basedb"
class Memory extends basedb

  showMem = ->
    log "Memory is now: \n" + JSON.stringify(db, null, 4) + "\n(#{ Object.keys(db).length } items)"

  # In-memory storage object
  db = {}

  delete: (path) ->
    delete db[path]

  update: (obj, callback) ->
    oldObj = db[obj.path]
    if oldObj
      for k of obj.obj
        oldObj[k] = obj.obj[k]

    else
      db[obj.path] = obj.obj

    showMem()

  deletePath: (thisPath) ->
    # Delete child objects under this path
    for path of db
      if path is thisPath or path.startsWith thisPath + "/"
        @delete path

  get: (path, callback) ->
    obj = db[path]
    if obj?
      # Object exists, return
      cb(obj)
    else
      cb(null)

  set: (obj, callback) ->
    log "Setting using: ", obj

    # Everything in obj.obj should be a primitive type
    # This is done by the flatenning algorithm on the Server-side

    objToSetIn = db[obj.path]
    if obj.obj is null
      delete db[obj.path]
    else
      db[obj.path] = {}
      objToSetIn = db[obj.path]
      for k of obj.obj
        objToSetIn[k] = obj.obj[k] if obj.obj[k] != null

    if isEmpty objToSetIn
      delete db[obj.path]

    showMem()

module.exports = Memory
