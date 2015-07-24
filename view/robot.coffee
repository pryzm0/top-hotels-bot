{ fork, spawn } = require 'child_process'

nconf = require '../config-app'
logger = require './logger'

module.exports = (app) ->
  app.get (req, res) ->
    logger.debug 'spawn log tail process'

    proc = spawn('sh', ['tail', nconf.get 'robot:log'])
      .on 'error', (error) ->
        logger.error { error }, 'tail process failed'
      .on 'exit', (code) ->
        logger.debug { code }, 'tail process exit'

    res.type 'text/plain'

    proc.stdout.pipe(res)
    proc.stdout.pipe(process.stdout)
    proc.stderr.pipe(process.stderr)

  app.post (req, res) ->
    logger.debug 'spawn robot process'

    proc = spawn('node', ['--harmony', 'robot/index.js', '--bformat:color='])
      .on 'error', (error) ->
        logger.error { error }, 'robot process failed'
      .on 'exit', (code) ->
        logger.debug { code }, 'robot process exit'

    res.type 'text/plain'

    proc.stdout.pipe(res)
    proc.stdout.pipe(process.stdout)
    proc.stderr.pipe(process.stderr)
