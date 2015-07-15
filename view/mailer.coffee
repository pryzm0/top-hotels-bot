fs = require 'fs'

filename = "#{__dirname}/../_mailer.log"
mailer = require '../mailer'

module.exports = (app) ->
  app.get (req, res) ->
    fs.readFile filename, { encoding: 'utf8' }, (err, content) ->
      log = (content.split '\n').reverse()
      log.shift() until log[0]

      res.type 'application/json'
      res.send "[#{log.slice(0, 200).join ','}]"

  app.post (req, res) ->
    mailer()
      .then -> res.sendStatus 200
      .fail -> res.sendStatus 404
