global.log = (msg) ->
  arguments_ = ['OpenFire [Server] -> ']
  for arg in arguments
    arguments_.push arg

  console.log.apply console, arguments_
