bunyan = require 'bunyan'

module.exports =
  robot: bunyan.createLogger {
    name: 'TopHotelsBot'
    serializers:
      res: bunyan.stdSerializers.res
    streams: [
      # { level: 'trace', stream: process.stdout },
      { level: 'info', path: '_robot.log' },
    ]
  }
  mailer: bunyan.createLogger {
    name: 'TopHotelsMailer'
    serializers:
      res: bunyan.stdSerializers.res
    streams: [
      # { level: 'trace', stream: process.stdout },
      { level: 'info', path: '_mailer.log' },
    ]
  }
