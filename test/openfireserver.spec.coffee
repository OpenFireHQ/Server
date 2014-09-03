mod = require "#{process.cwd()}/src/openfireserver"

describe 'OpenFireServer', ->
  it 'should exist', ->
    mod.should.be.ok
