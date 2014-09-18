ScriptHelper = require "./ScriptHelper"

class ServerInfo

  constructor: (@attrs, @bigDict) ->
    @script = new ScriptHelper(@bigDict)

  # todo
  on: (name, fn) ->

    # Server-side event


module.exports = ServerInfo
