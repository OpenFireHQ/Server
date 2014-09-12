class Validator
  constructor: (@db, @bigDict) ->

  accessesMeta: (path) ->
    return path.startsWith("/_meta")

  validate: (data, skipValidation, cb) ->
    { obj, path } = data

    if skipValidation
      cb()
      return

    if @accessesMeta path
      log "[Security] Someone tried to access the meta table from the client-side! Blocked."
      return

    cb()
    return

module.exports = Validator
