global.log = (msg) ->
  arguments_ = ['OpenFire [Server] -> ']
  for arg in arguments
    arguments_.push arg

  console.log.apply console, arguments_

unless typeof String::startsWith is "function"
  String::startsWith = (str) ->
    @slice(0, str.length) is str

global.isEmpty = (obj) ->
  for prop of obj
    return false  if obj.hasOwnProperty(prop)
  true
