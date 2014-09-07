# Start the OpenFire server with no DB and no extra validation
require "./global"
server = require "./openfireserver"
args = require('minimist')(process.argv.slice(3))
fs = require "fs"
colors = require('colors')
colors.setTheme
  silly: "rainbow"
  input: "grey"
  verbose: "cyan"
  prompt: "grey"
  info: "green"
  data: "grey"
  help: "cyan"
  warn: "yellow"
  debug: "blue"
  error: "red"


asciiArt = fs.readFileSync('./ascii.art').toString()
console.log asciiArt
command = process.argv[2]

commands =
  hack:
    desc: "Launches a simple in-memory OpenFire-database with full logging.\nIt does not need any extra setup and is great for starting quickly!"
    warn: "Data will be deleted when the server is shut-down"
    run: ->
      attrs = server.start(db: 'memory', logging: yes)
      showInfo attrs

showInfo = (attrs) ->
  { port, host } = attrs
  console.log "Running OpenFire Server on port #{port}"
  console.log "Connect to this DB using the OpenFire SDK:"
  console.log "    #{"db"} = #{"new".cyan} #{"OpenFire".yellow}(#{"\"http://127.0.0.1:5454/db\"".green});"
  console.log "You can replace /db by any namespace you want"

showCommands = ->
  console.log "Please supply a command!".warn + "\nValid commands are: ".help

  for k of commands
    c = commands[k]
    console.log k.bold
    console.log "  " + c.desc.replace(/\n/gi, "\n  ").info
    console.log "  " + c.warn.replace(/\n/gi, "\n  ").bold.warn if c.warn
    console.log "--".grey

for k of commands
  c = commands[k]
  if k is command
    c.run()
    break

  showCommands()
