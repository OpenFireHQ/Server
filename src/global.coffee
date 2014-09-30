global.log = (msg) ->
  arguments_ = ['OpenFire [Server] -> ']
  for arg in arguments
    arguments_.push arg

  console.log.apply console, arguments_

unless typeof String::startsWith is "function"
  String::startsWith = (str) ->
    @slice(0, str.length) is str

unless typeof String::endsWith is "function"
  String::endsWith = (suffix) ->
    @indexOf(suffix, @length - suffix.length) isnt -1

global.loopTillPath = (obj, name, cb) ->
  log 'loopTillPath: obj type: ', (typeof obj)
  if obj isnt null and typeof obj is 'object'
    for k of obj
      log "loopTillPath: must find #{name} in ", obj
      if k is name
        cb(k, obj[k])
        break
      else
        loopTillPath(obj[k], name, cb)
        break
  else
    cb(obj)

global.isEmpty = (obj) ->
  for prop of obj
    return false  if obj.hasOwnProperty(prop)
  true

global.displayObject = (obj) ->
  if obj isnt null and typeof obj is 'object'
    return JSON.stringify(obj, null, 4) + "\n(#{ Object.keys(obj).length } items)"
  else
    if obj is null
      return 'null'
    else
      return typeof obj

global.metaPath = "/_meta"
