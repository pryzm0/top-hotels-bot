sqlite3 = require 'sqlite3'
Q = require 'q'

storage = (db) -> {
  updateUser: (hotel, userData) -> Q.Promise (resolve) ->
    query = """
      INSERT INTO user_profile(href, username, fullname, address, date_in, hotel_id)
      VALUES ($href, $username, $fullname, $address, $date_in, $hotel)
    """

    db.run query, {
      $href: userData.href
      $username: userData.username
      $fullname: userData.fullname
      $address: userData.address
      $date_in: userData.date_in
      $hotel: hotel
    }, resolve

  listNotMailed: -> Q.Promise (resolve) ->
    query = """
      SELECT * FROM user_profile
      WHERE notification IS NULL
    """

    db.all query, (err, data) ->
      resolve data

  markMailed: (href) -> Q.Promise (resolve) ->
    query = """
      UPDATE user_profile
      SET notification = ?
      WHERE href = ?
    """

    now = 0 | (0.001 * Date.now())
    db.run query, [now, href], (err, data) ->
      resolve()
}

db = new sqlite3.Database '_database.sqlite'
module.exports = (storage db)
