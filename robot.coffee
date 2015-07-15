Q = require 'q'
_ = require 'lodash'

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
  nconf = (require 'nconf').file 'config.json'
  HOTELS = nconf.get 'hotels'

  startUrl = (HOTELS.map (id) -> "http://tophotels.ru/main/hotel/#{id}/travellers/future")
    .concat(HOTELS.map (id) -> "http://tophotels.ru/main/hotel/#{id}/travellers/now")

  (require './storage').then (storage) ->
    logger = (require './logger').robot

    robot = (task, doc) -> Q.fcall ->
      if task == 'initial'
        return startUrl.map (url) -> TaskUserList url, 0

      unless doc
        return null

      switch doc.entry
        when 'user-data'
          logger.info { id: doc.content.href, name: doc.content.fullname }, "=> #{task.target}"

          hotel = (task.target.match /hotel\/(\w+)/).pop()
          storage.updateUser hotel, doc.content

        when 'response-error'
          logger.warn { url: task.target }, "#{doc.content.statusCode}, retry #{task.retry}"
          return [TaskUserList task.target, (task.retry + 1)]

      return []

    schedule = (put) -> (task) ->
      if task.retry < 10
        _.delay (-> put task), task.retry * 15*1000

    (require 'wbt/reactor')(robot, schedule).then ->
      logger.info 'done'
