bunyan = require 'bunyan'
bformat = require 'bunyan-format'

nconf = require '../config-app'

module.exports = bunyan.createLogger {
  name: 'Mailer'
  serializers: bunyan.stdSerializers
  streams: [
    { level: 'trace', stream: bformat(nconf.get 'bformat') }
    { level: 'info', path: (nconf.get 'mailer:log') }
  ]
}
