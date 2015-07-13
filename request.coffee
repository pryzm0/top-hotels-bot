
module.exports = (require 'request').defaults {
  jar: true
  headers: {
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
    'Accept-Encoding': 'gzip, deflate, sdch'
    'Accept-Language': 'en-US,en;q=0.8,ru;q=0.6'
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/43.0.2357.81 Chrome/43.0.2357.81 Safari/537.36'
    'Referer': 'http://tophotels.ru/'
  }
}
