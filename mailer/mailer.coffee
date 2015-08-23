_ = require 'lodash'
Q = require 'q'
hbs = require 'handlebars'
moment = require 'moment'

nconf = require '../config-app'
logger = require './logger'

request = ((require 'request').defaults(
  (require '../config-app').get('mailer:request')))

matchDateIn = (value) ->
  dates = _.map (value.split /\s*-\s*/), (str) ->
    moment(str, 'DD-MM-YYYY').toDate()
  logger.debug 'match date in', value, dates
  unless dates.length == 2
    return false
  days = Math.floor (dates[0].getTime() - Date.now()) / (24*60*60*1000)
  logger.debug 'days', days
  return days < 14

MailerSafe =
  login: (auth) ->
    logger.debug { auth }, '=> login'
    Q.resolve()

  logout: ->
    logger.debug '<= logout'
    Q.resolve()

  send: (href, message, subj) ->
    logger.debug { href, message, subj }, 'send'
    Q.resolve()

Mailer =
  login: ({ email, password }) -> Q.Promise (resolve, reject) ->
    logger.debug '=> login'
    actionUrl = 'http://tophotels.ru/main/auth/login/'
    formData = {
      login: email
      pass: password
      back: 'http://tophotels.ru'
    }
    request.post actionUrl, { form: formData }, (err, response) ->
      unless err then resolve()
      else reject(err or "status: #{response.statusCode}")

  logout: -> Q.Promise (resolve) ->
    logger.debug '<= logout'
    actionUrl = 'http://tophotels.ru/main/auth/logout/'
    request.get actionUrl, (err, response) ->
      unless err then resolve()
      else reject(err)

  send: (href, message, theme) -> Q.Promise (resolve, reject) ->
    logger.debug 'send to', href
    actionUrl = 'http://tophotels.ru/actions/send_user_message/'
    formData = {
      user_id: href.split('/').pop()
      rate_id: 0
      type: 1
      theme: theme
      message: message
    }
    request.post actionUrl, { form: formData }, (err, response) ->
      if not err and response.statusCode == 200 then resolve()
      else reject response.statusCode

module.exports = ->
  unless nconf.get 'mailer:simulate'
    logger.info 'start'
    mailer = Mailer
  else
    logger.info 'start (simulate)'
    mailer = MailerSafe

  { theme, template } = nconf.get 'mailer:content'
  mailTemplate = hbs.compile template

  mailUser = (user) ->
    message = mailTemplate { user }
    mailer.send(user.href, message, theme)
      .then -> logger.info { href: user.href }, 'sent ok'
      .fail (error) -> logger.error { error }, 'send fail'

  (require '../storage_sqlite3').then (storage) ->
    auth = nconf.get 'mailer:auth'

    mailer.login(auth)
      .then -> logger.debug '=> ok'
      .then -> storage.listNotMailed()
      .then (users) ->
        users = _.filter users, (user) ->
          matchDateIn user.date_in

        logger.info "#{users.length} messages in queue"

        Q.allSettled users.map (user) ->
          mailUser(user).then ->
            unless nconf.get 'mailer:simulate'
              storage.markMailed user.href

      .then -> logger.info 'complete'
      .then -> mailer.logout()
      .then -> logger.debug '<= ok'
      .then -> logger.info 'finish'
      .fail (error) -> logger.error { error }, 'general fail'
