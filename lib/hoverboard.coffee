express = require "express"
eventTap = require "event-tap"
app = express()

helperContext = {}
app.configure ->
  app.use(express.methodOverride());
  app.use(express.bodyParser());
  app.set('view engine', 'ejs');
  app.use require('connect-assets')({src: __dirname + "/../assets"})
  app.use(express.static(__dirname + '/../static'));
  app.use(express.errorHandler({
    dumpExceptions: true,
    showStack: true
  }));
  app.use(app.router);

app.get '/', (req, res) ->
  res.render('index')

app.post '/keydown-event/:keyCode', (req, res) ->
  {keyCode} = req.params
  eventTap.postKeyboardEvent(parseInt(keyCode))
  res.end()

exports.start = (port=8080) -> app.listen(8080)