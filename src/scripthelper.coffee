slug = require('slug')

class ScriptHelper

  constructor: (@bigDict) ->

  push: (name, fn) ->

    @bigDict.update(
      path: metaPath + "/scripts/" + slug(name)
      obj: {
        fn: fn.toString()
        name: name
      }
    )

module.exports = ScriptHelper
