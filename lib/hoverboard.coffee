ws = require "ws"
http = require 'http'
express = require "express"
eventTap = require "event-tap"

appServer = express()
httpServer = http.createServer appServer
socketServer = new ws.Server({server: httpServer})

appServer.configure ->
  appServer.use express.methodOverride()
  appServer.use express.bodyParser()
  appServer.set 'view engine', 'ejs'
  appServer.use require('connect-assets')({src: __dirname + "/../assets"})
  appServer.use express.static(__dirname + '/../static');
  appServer.use express.errorHandler({dumpExceptions: true, showStack: true })
  appServer.use appServer.router

appServer.get '/', (req, res) ->
  res.render 'index'

socketServer.on 'connection', (socket) ->
  currentMouseLocation = eventTap.getMouseLocation()

  socket.on 'message', (message) ->
    event = JSON.parse message

    switch event.type
      when 'keyDown'
        eventTap.postKeyboardEvent parseInt(event.keyCode)
      when 'mouseMove'
        eventTap.postMouseEvent \
          currentMouseLocation.x += event.x, currentMouseLocation.y += event.y

exports.start = (port=8080) -> httpServer.listen(8080)
