ws = require "ws"
http = require 'http'
express = require "express"
eventTap = require "event-tap"

hoverboard = express()
httpServer = http.createServer hoverboard

hoverboard.configure ->
  hoverboard.use express.methodOverride()
  hoverboard.use express.bodyParser()
  hoverboard.set 'view engine', 'ejs'
  hoverboard.use require('connect-assets')({src: __dirname + "/../assets"})
  hoverboard.use express.static(__dirname + '/../static');
  hoverboard.use express.errorHandler({dumpExceptions: true, showStack: true })
  hoverboard.use hoverboard.router

hoverboard.get '/', (req, res) ->
  res.render 'index'

hoverboard.post '/keydown-event/:keyCode', (req, res) ->
  {keyCode} = req.params
  eventTap.postKeyboardEvent parseInt(keyCode)
  res.end()

socketServer = new ws.Server({server: httpServer})

socketServer.on 'connection', (socket) ->
  socket.on 'message', (message) ->
    console.log message

exports.start = (port=8080) -> httpServer.listen(8080)
