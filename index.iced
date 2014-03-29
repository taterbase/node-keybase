API       = 'https://keybase.io/_/api/1.0'
crypto    = require 'crypto'
triplesec = require 'triplesec'
request   = require 'request'
constants = require './constants.js'

getsalt = (usernameOrEmail, cb) ->
  await request.get {
    url: API + '/getsalt.json?email_or_username=' + usernameOrEmail
    json: true
  }, defer err, res, body

  cb err, body

authorize = (email_or_username, passphrase, cb) ->

  await getsalt email_or_username, defer err, result

  return cb err if err?

  if result.status.code isnt 0
    return cb new Error("An error occured: " + JSON.stringify(result))

  salt          = new Buffer result.salt, 'hex'
  csrf          = result.csrf_token
  login_session = result.login_session

  enc = new triplesec.Encryptor
    key: new Buffer(passphrase, 'utf8'),
    version: 3
    
  extra_keymaterial = constants.pwh.derived_key_bytes + constants.openpgp.derived_key_bytes
    
  await enc.resalt {salt, extra_keymaterial}, defer err, km

  pwh = km.extra.slice(0, constants.pwh.derived_key_bytes)
  hmac_pwh = crypto.createHmac('SHA512', pwh)
                   .update(new Buffer(login_session, 'base64'))
                   .digest('hex')

  request.post {
    url: API + '/login.json'
    body:
      email_or_username: email_or_username
      hmac_pwh: hmac_pwh
      login_session: login_session
    json: true
  }, cb

module.exports = {authorize}
