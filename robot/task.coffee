
logger = require './logger'
nconf = require '../config-app'

class LocalAgent

  request = (require 'request')
    .defaults( (nconf.get 'robot:request') ? {} )
  iconv = require 'iconv-lite'

  fetch: (url) ->
    logger.debug '->', url
    request(url)
      .on 'response', (response) ->
        logger.debug '<-', response.statusCode, url
      .on 'error', (error) ->
        logger.error { error }, url
      .pipe(iconv.decodeStream 'win1251')


{ DomCropper } = require 'wbt/cropper/dom'
_ = require 'lodash'

agent = new LocalAgent()

module.exports = _.curry (name, parsers, url, retry) -> {
  task: name
  agent: agent
  target: url
  retry: retry
  croppers: [DomCropper]
  buffer: 50
  dom: parsers
}
