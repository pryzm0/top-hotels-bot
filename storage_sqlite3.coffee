sqlite3 = require 'sqlite3'
Q = require 'q'

storage = (db) -> {
  updateUser: (hotel, userData) -> Q.Promise (resolve) ->
    qs = """
      INSERT INTO user_profile(href, username, fullname, address, date_in, hotel_id)
      VALUES ($href, $username, $fullname, $address, $date_in, $hotel)
    """

    db.run qs, {
      $href: userData.href
      $username: userData.username
      $fullname: userData.fullname
      $address: userData.address
      $date_in: userData.date_in
      $hotel: hotel
    }, -> resolve()

  listNotMailed: -> Q.Promise (resolve) ->
    qs = """
      SELECT * FROM user_profile
      WHERE notification IS NULL
    """

    db.all qs, (err, rows) ->
      resolve rows

  markMailed: (href) -> Q.Promise (resolve) ->
    qs = """
      UPDATE user_profile
      SET notification = ?
      WHERE href = ?
    """

    now = 0|(0.001*Date.now())
    db.run qs, [now, href], (err, result) ->
      resolve()
}


module.exports = Q.Promise (resolve, reject) ->
  db = new sqlite3.Database '_database.sqlite'
  resolve storage(db)
