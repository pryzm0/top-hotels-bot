fs = require 'fs'

module.exports = (app) ->
  app.get (req, res) ->
    res.sendFile 'config.json', root: process.cwd()

  app.post (req, res) ->
    config = JSON.stringify req.body
    fs.writeFile "#{process.cwd()}/config.json", config, ->
      res.sendStatus 200
