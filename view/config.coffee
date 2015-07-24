CONFIG = 'config-local.json'

fs = require 'fs'

module.exports = (app) ->
  app.get (req, res) ->
    res.sendFile CONFIG, root: process.cwd()

  app.post (req, res) ->
    fs.writeFile CONFIG, (JSON.stringify req.body, null, '  '), ->
      res.sendStatus 200
