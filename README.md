# OpenFire Server [![Build Status](https://travis-ci.org/OpenFireHQ/Server.svg?branch=master)](https://travis-ci.org/OpenFireHQ/Server)

> Server for the OpenFire Project

### What is OpenFire?

OpenFire is an Open Source Database & Backend Engine. Use our JavaScript SDK to connect your web services directly to the server, and interact with your objects immediatly and realtime!

### Getting started

This guide is for developers who want to get started immediatly.

**Install OpenFire**
```bash
npm install -g openfire
```
If that doesn't work, try append sudo to run installation as root.

**Start hacking!**
This command will launch a in-memory server, with zero dependencies.
Keep in mind that when you close this server the data is gone.
```bash
openfire hack
```

It's that simple :) Now let's put our db to work, shall we?
The following example is a realtime visitor-counter, and demonstrates various functions available in the OpenFire SDK.

Create a file with a `.html` extension, and paste the following code.
Then just open the file on a few tabs, maybe even on your mobile device and watch the counter jump!
```html
<!DOCTYPE html>
<html>
  <title>Visitor Counter</title>
  <body>
    <h3>Welcome! There are currently &nbsp;<span id="counter"></span>&nbsp; People watching this site!</h3>
  </body>
  <script src="http://openfi.re/openfire.js"></script>
  <script>
    // Intialize our DB
    // getting-started is our namespace for this example project
    var db = new OpenFire("http://localhost:5454/getting-started");

    // connections is where we drop our users connection data in
    var connections = db.child("connections");

    // connectedChild is the unique object
    // we hold the current connection for this client in
    var connectedChild = null;

    // This function get's called every time the connections object changes.
    var connectionsChange = function(sn) {
        if (sn.val != null) {
            // Get the count
            var count = sn.childCount();

            // Set the count to our counter in HTML
            document.getElementById("counter").innerHTML = count;
        }
    };

    // Hook connectionsChange event to "value"
    // The server will call this to us each time the value of connections change.
    connections.on("value", connectionsChange);
    connections.on("connect", function() {
        // On connect, use push to create a new child inside connections
        // And set it to true to mark the connected state
        connectedChild = connections.push();
        connectedChild.set(true);

        // Use setAfterDisconnect to make sure that the value gets deleted
        // (set to null equals deletion in OpenFire)
        // to guarantee the counter only count our current visitors
        connectedChild.setAfterDisconnect(null);
    });
  </script>
</html>
```

As you can see it's not that hard to create fairly complex dynamic web apps with OpenFire.
**Currently OpenFire is in beta, and I'll try to make better documentation in the next week**!


### Testing

watches for file changes and reruns tests each time
```bash
  $ grunt watch
```

runs spec tests
```bash
  $ grunt test  
```

produces coverage report (needs explicit piping)
```bash
  $ grunt cov
```

### Roadmap

The reason for me releasing this project already is to gain initial feedback and to see if more people like the idea.

OpenFire is definitely **not** production ready yet. It lacks certain features for running a stable server, like wrappers for a proper database like MongoDB or Redis, also there are no security settings yet for you to configure.

I’m planning to use OpenFire long-term for my next projects and can’t wait to see it production ready.
The following features are planned short-term:

 – Database support (I start first with MongoDB I think, as it’s the most general-purpose database suitable for this kind of work)
 
 – Offline compatibility in the SDK
 
 – Security (validate data before storing in the database)

## License

GPLv2
