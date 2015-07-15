USERNAME = 'admin'
PASSWORD = 'finnjake'

http = require 'http'
express = require 'express'
basicAuth = require 'basic-auth'
bodyParser = require 'body-parser'

app = express()

app.use (req, res, next) ->
  unauthorized = ->
    res.set 'WWW-Authenticate', 'Basic realm=Authorization required'
    res.sendStatus 401

  user = basicAuth req

  unless user and user.name and user.pass
    return unauthorized()

  unless user.name == USERNAME and user.pass == PASSWORD
    return unauthorized()

  next()

app.use bodyParser.json()

app.use '/static', (express.static './bower_components')
app.use '/', (express.static './www')

(require './view/config')(app.route '/api/config')
(require './view/robot')(app.route '/api/robot')
(require './view/mailer')(app.route '/api/mailer')

server = http.createServer app

server.listen (port = process.env.PORT ? 8080), ->
  console.log 'Listening on', port


# # Run robot every 12 minutes.
# setInterval (require './robot'), 12*60*1000
