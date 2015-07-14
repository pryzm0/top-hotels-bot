Q = require 'q'

storage = (client) -> {
  updateUser: (hotel, userData) -> Q.Promise (resolve) ->
    qs = """
      INSERT INTO user_profile(href, username, fullname, address, date_in, hotel_id)
      VALUES ($1, $2, $3, $4, $5, $6)
    """

    param = [
      userData.href
      userData.username
      userData.fullname
      userData.address
      userData.date_in
      hotel
    ]

    client.query qs, param, (err, result) ->
      resolve()

  listNotMailed: -> Q.Promise (resolve) ->
    qs = """
      SELECT * FROM user_profile
      WHERE notification IS NULL
    """

    client.query qs, (err, result) ->
      resolve result.rows

  markMailed: (href) -> Q.Promise (resolve) ->
    qs = """
      UPDATE user_profile
      SET notification = NOW()
      WHERE href = $1
    """

    client.query qs, [href], (err, result) ->
      resolve()
}


module.exports = Q.Promise (resolve, reject) ->
  (require 'pg').connect process.env.DATABASE_URL, (err, client) ->
    unless err then resolve storage(client)
    else reject err
