triplesec = require 'triplesec'
constants = require '../constants'
crypto = require 'crypto'
{BufferOutStream} = require 'iced-spawn'
{master_ring} = require('gpg-wrapper').keyring
{make_esc} = require 'iced-error'
KeyManager = require('kbpgp').KeyManager
Encryptor = require('triplesec').Encryptor

class StatusParser
  constructor : () ->
    @_all = []
    @_table = []

  parse : ({buf}) ->
    lines = buf.toString('utf8').split /\r?\n/
    for line in lines
      words = line.split /\s+/
      if words[0] is '[GNUPG:]'
        @_all.push words[1...]
        @_table[words[1]] = words[2...]
    @

  lookup : (key) -> @_table[key]

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

  import_from_p3skb : ( {raw, passphrase}, cb ) ->
    esc = make_esc cb, "NodeKeybase::import_from_p3skb"
    await KeyManager.import_from_p3skb {raw}, esc defer km, warnings

    await km.unlock_p3skb {tsenc: new Encryptor(key: new Buffer(passphrase, 'utf8'))}, esc defer()

    await km.sign {}, esc defer()

    await km.export_pgp_private_to_client {passphrase}, defer err, key_data
    cb err, key_data

  #gen_key: ({username, passphrase}, cb) ->
  #  ring = master_ring()
  #  console.log ring
  #  host = constants.canonical_host
  #  email = "#{username}@#{host}"
  #  script = [
  #    "%echo generating"
  #    "Key-Type: RSA"
  #    "Key-Length: #{constants.keygen.master.bits}"
  #    "Key-Usage: sign,auth"
  #    "Subkey-Type: RSA"
  #    "Subkey-Length: #{constants.keygen.subkey.bits}"
  #    "Subkey-Usage: encrypt"
  #    "Name-Real: #{host}/#{username}"
  #    "Name-Email: #{email}"
  #    "Expire-date: #{constants.keygen.expire}"
  #    "Passphrase: #{passphrase}"
  #    "%commit"
  #  ]
  #  stdin = script.join("\n")
  #  args = [ "--batch", "--gen-key", "--keyid-format", "long", "--status-fd", '2' ]
  #  stderr = new BufferOutStream()
  #  await ring.gpg { args, stdin, stderr, secret : true }, defer err, out
  #  if err?
  #    console.log "Error: #{stderr.data().toString()}"
  #  else
  #    status_parser = (new StatusParser).parse { buf : stderr.data() }
  #    if (kc = status_parser.lookup('KEY_CREATED'))? and kc.length >= 2
  #      fingerprint = kc[1]
  #      key = ring.make_key { fingerprint, secret : true }
  #      await key.load esc defer()
  #    else
  #      err = new Error "Failed to parse output of key generation"
  #  cb err
