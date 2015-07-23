nconf = (require 'nconf').argv().defaults {
  username: 'admin'
  password: 'finnjake'
  host: '127.0.0.1'
  port: 8080
  static:
    serve: true
    dir: {
      '/static': './bower_components'
      '/': './www'
    }
}

http = require 'http'
express = require 'express'
basicAuth = require 'basic-auth'
bodyParser = require 'body-parser'

app = express()

if nconf.get 'username'
  app.use (req, res, next) ->
    unauthorized = ->
      res.set 'WWW-Authenticate', 'Basic realm=Authorization required'
      res.sendStatus 401

    user = basicAuth req

    unless user and user.name and user.pass
      return unauthorized()

    unless user.name == (nconf.get 'username') and user.pass == (nconf.get 'password')
      return unauthorized()

    next()

app.use bodyParser.json()

if nconf.get 'static:serve'
  for own path, dir of nconf.get 'static:dir'
    app.use path, (express.static dir)

(require './view/config')(app.route '/api/config')
(require './view/robot')(app.route '/api/robot')
(require './view/mailer')(app.route '/api/mailer')

server = http.createServer app

server.listen (nconf.get 'port'), (nconf.get 'host'), ->
  console.log 'Listening on', "#{nconf.get 'host'}:#{nconf.get 'port'}"

# # Run robot every 12 minutes.
# setInterval (require './robot'), 12*60*1000
