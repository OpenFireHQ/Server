class Validator
  constructor: (@db, @bigDict) ->

  validate: (data, cb) ->
    { obj, path } = data

    if path.startsWith("/_meta")
      log "[Security] Someone tried to access the meta table from the client-side! Blocked."
      return

    cb()
    return

module.exports = Validator
