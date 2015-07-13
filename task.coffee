
class LocalAgent

  request = require './request'
  iconv = require 'iconv-lite'

  fetch: (url) ->
    try
      req = request(url)
        .on('response', (response) -> req.emit 'response', response)
        .pipe(iconv.decodeStream 'win1251')
      return req
    catch e
      console.log 'ERROR', e


agent = new LocalAgent()

_ = require 'lodash'

{ DomCropper } = require 'wbt/cropper/dom'

class OkDomCropper extends DomCropper

  consume: (stream, task) ->
    stream.on 'response', (response) =>
      unless 200 <= response.statusCode < 300
        @emit 'document', {
          entry: 'response-error'
          content: response
        }

    super(stream, task)


module.exports = _.curry (name, parsers, url, retry) -> {
  task: name
  agent: agent
  target: url
  retry: retry
  croppers: [OkDomCropper]
  buffer: 50
  dom: parsers
}
