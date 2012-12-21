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

  socket.on 'message', (message) ->
    event = JSON.parse message

    switch event.type
      when 'keyDown'
        eventTap.postKeyboardEvent parseInt(event.keyCode)
      when 'mouseMoved', 'leftMouseDown', 'leftMouseUp', 'rightMouseDown', 'rightMouseUp', 'leftMouseDragged', 'rightMouseDragged'
        currentMouseLocation = eventTap.getMouseLocation()
        x = currentMouseLocation.x + event.x
        y = currentMouseLocation.y + event.y

        eventTap.postMouseEvent event.type, x, y

exports.start = (port=8080) -> httpServer.listen(8080)
