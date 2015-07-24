{ fork, spawn } = require 'child_process'

nconf = require '../config-app'
logger = require './logger'

module.exports = (app) ->
  app.get (req, res) ->
    logger.debug 'spawn log tail process'

    proc = spawn('sh', ['tail', nconf.get 'mailer:log'])
      .on 'error', (error) ->
        logger.error { error }, 'tail process failed'
      .on 'exit', (code) ->
        logger.debug { code }, 'tail process exit'

    res.type 'text/plain'

    proc.stdout.pipe(res)
    proc.stdout.pipe(process.stdout)
    proc.stderr.pipe(process.stderr)

  app.post (req, res) ->
    logger.debug 'spawn mailer process'

    proc = spawn('node', ['--harmony', 'mailer/index.js', '--bformat:color='])
      .on 'error', (error) ->
        logger.error { error }, 'mailer process failed'
      .on 'exit', (code) ->
        logger.debug { code }, 'mailer process exit'

    res.type 'text/plain'

    proc.stdout.pipe(res)
    proc.stdout.pipe(process.stdout)
    proc.stderr.pipe(process.stderr)
