Q = require 'q'
hbs = require 'handlebars'
fs = require 'fs'

request = require './request'
storage = require './storage'
logger = (require './logger').mailer

nconf = (require 'nconf').file 'config.json'
mailTemplate = hbs.compile (fs.readFileSync nconf.get('template')).toString()


login = -> Q.Promise (resolve, reject) ->
  actionUrl = 'http://tophotels.ru/main/auth/login/'
  formData = {
    login: nconf.get('email')
    pass: nconf.get('password')
    back: 'http://tophotels.ru'
  }
  request.post actionUrl, { form: formData }, (err, response) ->
    if response.statusCode == 302 then resolve()
    else reject "Login failed. Status #{response.statusCode}"

logout = -> Q.Promise (resolve) ->
  actionUrl = 'http://tophotels.ru/main/auth/logout/'
  request actionUrl, (err, response) ->
    resolve()

mail = (userId, message, subj) -> Q.Promise (resolve, reject) ->
  actionUrl = 'http://tophotels.ru/actions/send_user_message/'
  formData = {
    user_id: userId
    rate_id: 0
    type: 1
    theme: subj
    message: message
  }
  request.post actionUrl, { form: formData }, (err, response) ->
    if response.statusCode == 200 then resolve()
    else reject "Send message failed. Status #{response.statusCode}"

login()
  .then -> logger.info 'login ok'
  .then -> storage.listNotMailed()
  .then (users) ->
    logger.info "#{users.length} messages to send"

    subj = nconf.get('subject')
    Q.allSettled users.map (user) ->
      userId = user.href.split('/').pop()
      message = mailTemplate user
      mail(userId, message, subj)
        .then ->
          logger.info "message is sent to #{user.fullname} (#{userId})"
          storage.markMailed user.href
        .fail (err) ->
          logger.error { message: err }, "failed to send message to #{user.fullname} (#{userId})"
  .then -> logger.info 'job done. logout'
  .fin -> logout()
