server = require "#{process.cwd()}/src/openfireserver"

describe 'OpenFireServer', ->
  it 'should start', ->
    server.start(
      port: 5454
      db: 'memory'
    )
