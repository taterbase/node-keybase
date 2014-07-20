API       = 'https://keybase.io/_/api/1.0'
crypto    = require 'crypto'
triplesec = require 'triplesec'
request   = require 'request'
constants = require './constants'

Keybase = (@usernameOrEmail, @passphrase)->

Keybase.prototype.getsalt = (usernameOrEmail, cb) ->
  if arguments.length isnt 2
    cb = arguments[0]

    if not @usernameOrEmail
      return cb new Error "No username or email provided"

  else
    @usernameOrEmail = usernameOrEmail

  await request.get {
    url: API + '/getsalt.json?email_or_username=' + @usernameOrEmail
    json: true
  }, defer err, res, body

  cb err, body

Keybase.prototype.login = (usernameOrEmail, passphrase, cb) ->
  if arguments.length isnt 3
    cb = arguments[0]

    if not @usernameOrEmail or not @passphrase
      return cb new Error("You must pass in an email/username and passphrase")

  else
    @usernameOrEmail = usernameOrEmail
    @passphrase = passphrase

  await @getsalt defer err, result

  return cb err if err?

  if result.status.code isnt 0
    return cb new Error("An error occured: " + JSON.stringify(result))

  salt          = new Buffer result.salt, 'hex'
  login_session = result.login_session

  enc = new triplesec.Encryptor
    key: new Buffer(@passphrase, 'utf8'),
    version: 3
    
  extra_keymaterial = constants.pwh.derived_key_bytes + constants.openpgp.derived_key_bytes
    
  await enc.resalt {salt, extra_keymaterial}, defer err, km

  pwh = km.extra.slice(0, constants.pwh.derived_key_bytes)
  hmac_pwh = crypto.createHmac('SHA512', pwh)
                   .update(new Buffer(login_session, 'base64'))
                   .digest('hex')

  await request.post {
    url: API + '/login.json'
    body:
      email_or_username: @usernameOrEmail
      hmac_pwh: hmac_pwh
      login_session: login_session
    json: true
  }, defer err, res, body

  @session = body?.session
  @csrf_token = body?.csrf_token

  cb err, body

Keybase.prototype.user_lookup = (options, cb) ->
  queryString = ''

  if options.usernames and not Array.isArray(options.usernames)
    return cb new Error "Pass usernames in as an array of strings"
  else if options.fields and not Array.isArray(options.fields)
    return cb new Error "Pass fields in as an array of strings"

  Object.keys(options).forEach (key) ->
    queryString += if queryString.length == 0 then '?' else '&'
    queryString += key + '='
    option = options[key]

    queryString += if Array.isArray(option) then option.join(',') else option

  await request.get {
    url: API + '/user/lookup.json' + queryString
    json: true
  }, defer err, res, body

  cb err, body

Keybase.prototype.user_autocomplete = (string, cb) ->
  await request.get {
    url: API + '/user/autocomplete.json?q=' + string
    json: true
  }, defer err, res, body

  cb err, body

Keybase.prototype.public_key_for_username = (username, cb) ->
  await request.get {
    url: "https://keybase.io/#{username}/key.asc"
  }, defer err, res, body

  cb err, body

Keybase.prototype.key_add = (options, cb) ->
  if not @session
    console.log "Not logged in, attempting to authorize"

    await @authorize defer err
    if err
      return cb new Error "Unable to authorize. Please login before adding a key"

  options['session'] = options['session'] or @session
  options['csrf_token'] = options['csrf_token'] or @csrf_token

  await request.post {
    url: "#{API}/key/add.json"
    json: true
    body: options
  }, defer err, res, result

  cb err, result

Keybase.prototype.key_fetch = (options, cb) ->
  cb new Error("Not impl'd")

Keybase.prototype.key_revoke = (options, cb) ->
  if arguments.length isnt 2
    cb = arguments[0]
    options = {}

  if not @session
    console.log "Not logged in, attempting to authorize"

    await @authorize defer err
    if err
      return cb new Error "Unable to authorize. Please login before adding a key"

  options['revocation_type'] = options['revocation_type'] or 0
  options['csrf_token'] = options['csrf_token'] or @csrf_token
  options['session'] = options['session'] or @session

  if options['kid'] is undefined then options['revoke_primary'] = 1

  await request.post {
    url: "#{API}/key/revoke.json"
    json: true
    body: options
  }, defer err, res, result

  cb err, result

module.exports = Keybase
