basedb = require "./basedb"
class Memory extends basedb

  # In-memory storage object
  db = {}

  delete: (path) ->
    delete db[path]

  set: (obj, callback) ->

    db[obj.path] = obj.obj

    log "Created object, memory is now: ", db

module.exports = Memory
