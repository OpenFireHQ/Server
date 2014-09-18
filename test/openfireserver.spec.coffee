server = require "#{process.cwd()}/src/openfireserver"
serverinfo = null

describe 'OpenFireServer', ->
  it 'should start', ->
    serverinfo = server.start(
      port: 5454
      db: 'memory'
      logging: yes
    )

describe 'DB Scripting', ->

  it 'should be able to access scripting api', ->
    console.log serverinfo.script

  it 'should be able to push script', ->
    serverinfo.script.push("test", ->
      console.log('hello')
    )
