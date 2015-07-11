SAFARI_IPAD = 'Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25'
ICEWEASEL = 'Mozilla/5.0 (X11; Linux x86_64; rv:17.0) Gecko/20121202 Firefox/17.0 Iceweasel/17.0.1'

random = (arr) -> arr[Math.floor arr.length * Math.random()]

request = require 'request'
iconv = require 'iconv-lite'
touch = require 'touch'
FileCookieStore = require 'tough-cookie-filestore'


class LocalAgent

  COOKIE_JAR_FILE = '_cookiejar.json'

  touch.sync(COOKIE_JAR_FILE)

  _request = request.defaults {
    headers: {
      'User-Agent': ICEWEASEL
    }
    jar: (request.jar new FileCookieStore(COOKIE_JAR_FILE))
  }

  fetch: (url) ->
    try
      req = _request(url)
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
