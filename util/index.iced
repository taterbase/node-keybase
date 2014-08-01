triplesec = require 'triplesec'
constants = require '../constants'
crypto = require 'crypto'

module.exports =

  gen_pwh: ({passphrase, salt}, cb) ->
    if not (salt instanceof Buffer) then salt = new Buffer salt, 'hex'

    enc = new triplesec.Encryptor
      key: new Buffer(passphrase, 'utf8'),
      version: constants.triplesec.version
      
    extra_keymaterial = constants.pwh.derived_key_bytes + constants.openpgp.derived_key_bytes

    await enc.resalt {salt, extra_keymaterial}, defer err, km

    unless err?
      _pwh = km.extra.slice(0, constants.pwh.derived_key_bytes)
      _salt = enc.salt.to_buffer()
      _pwh_version = triplesec.CURRENT_VERSION

    cb err, _pwh, _salt, _pwh_version

  gen_hmac_pwh : ( {passphrase, salt, login_session}, cb) ->
    await module.exports.gen_pwh { passphrase, salt }, defer err, pwh

    unless err?
      hmac_pwh = crypto.createHmac('SHA512', pwh)
                       .update(new Buffer(login_session, 'base64'))
                       .digest('hex')

    cb err, hmac_pwh
