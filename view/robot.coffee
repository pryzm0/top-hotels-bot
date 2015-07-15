fs = require 'fs'

filename = "#{process.cwd()}/_robot.log"
robot = require '../robot'

module.exports = (app) ->
  app.get (req, res) ->
    fs.readFile filename, { encoding: 'utf8' }, (err, content) ->
      log = (content.split '\n').reverse()
      log.shift() until log[0]

      res.type 'application/json'
      res.send "[#{log.slice(0, 200).join ','}]"

  app.post (req, res) ->
    robot()
      .then -> res.sendStatus 200
      .fail -> res.sendStatus 404
