fs = require 'fs'

module.exports = (app) ->
  app.get (req, res) ->
    res.sendFile 'config.json', root: "#{__dirname}/../"

  app.post (req, res) ->
    config = JSON.stringify req.body
    fs.writeFile "#{__dirname}/../config.json", config, ->
      res.sendStatus 200
