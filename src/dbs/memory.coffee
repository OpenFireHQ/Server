basedb = require "./basedb"
class Memory extends basedb

  showMem = ->
    log "Updated object, memory is now (#{ Object.keys(db).length } items): \n", db

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

  set: (obj, callback) ->

    # Delete child objects under this path
    for path of db
      if path.startsWith obj.path
        @delete path

    db[obj.path] = obj.obj
    showMem()

module.exports = Memory
