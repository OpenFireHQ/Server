# Start the OpenFire server with no DB and no extra validation
server = require "./openfireserver"
require "./global"

server.start(
  db: "memory"
)

log "Server running at http://127.0.0.1:5454/"
log 'Connect to this DB using the OpenFire SDK: db = new OpenFire("http://127.0.0.1:5454/db");'
log 'You can replace /db by any namespace you want'
