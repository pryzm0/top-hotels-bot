Q = require 'q'
_ = require 'lodash'

nconf = require '../config-app'
logger = require './logger'

parseUserList = ($) ->
  (($ 'tr.tourists-item-tr').map (k, elem) -> {
    entry: 'user-data'
    content:
      href: ($ elem).find('a.tourists-item-user-link').attr('href')
      username: ($ elem).find('a.tourists-item-user-link').text().trim()
      fullname: ($ elem).find('span.tourists-item-name').text()
      address: ($ elem).find('span.tourists-item-adress').text().replace(/\s+/g, ' ').trim()
      date_in: ($ elem).find('div.tourists-item-date').text()
  }).get()

TaskDef = require './task'
TaskUserList = TaskDef 'parse-user-list', [parseUserList]

module.exports = ->
  logger.debug { config: nconf.get 'robot' }, 'start'

  hotels = nconf.get 'robot:target:hotels'
  startUrl = (hotels.map (id) -> "http://tophotels.ru/main/hotel/#{id}/travellers/future")
    .concat(hotels.map (id) -> "http://tophotels.ru/main/hotel/#{id}/travellers/now")

  (require '../storage_sqlite3').then (storage) ->
    robot = (task, doc) -> Q.fcall ->
      if task == 'initial'
        logger.info 'initial task: crawl', startUrl.length, 'pages'
        return startUrl.map (url) -> TaskUserList url, 0

      unless doc
        logger.warn 'no doc received'
        return null

      switch doc.entry
        when 'user-data'
          logger.info {
            href: doc.content.href
            fullname: doc.content.fullname
          }, "=> #{task.target}"

          hotel = (task.target.match /hotel\/(\w+)/).pop()
          storage.updateUser hotel, doc.content

        when 'response-error'
          logger.warn { url: task.target }, "#{doc.content.statusCode}, retry #{task.retry}"
          return [TaskUserList task.target, (task.retry + 1)]

      return []

    schedule = (put) -> (task) ->
      if task.retry < 10
        _.delay (-> put task), task.retry * 15*1000

    logger.debug 'run reactor'

    (require 'wbt/reactor')(robot, schedule).then ->
      logger.info 'finish'
