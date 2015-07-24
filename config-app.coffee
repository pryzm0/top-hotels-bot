defaultHeaders =
  'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
  'Accept-Encoding': 'gzip, deflate, sdch'
  'Accept-Language': 'en-US,en;q=0.8,ru;q=0.6'
  'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/43.0.2357.81 Chrome/43.0.2357.81 Safari/537.36'
  'Referer': 'http://tophotels.ru/'


module.exports = (require 'nconf')
  .argv()
  .file 'config-local.json'
  .defaults {
    username: 'admin'
    password: 'finnjake'
    host: '127.0.0.1'
    port: 8080
    storage:
      sqlite3: '_database.sqlite'
    bformat:
      outputMode: 'short'
      color: false
    robot:
      request: { gzip: true, jar: true, headers: defaultHeaders }
      log: '_robot.log'
      target:
        hotels: []
    mailer:
      request: { gzip: true, jar: true, headers: defaultHeaders }
      log: '_mailer.log'
      simulate: true
      auth:
        email: ''
        password: ''
      content:
        theme: ''
        template: ''
    static:
      serve: true
      dir: {
        '/static': './bower_components'
        '/': './www'
      }
  }
