API       = 'https://keybase.io/_/api/1.0'
request   = require 'request'
util      = require './util'

noop = (func_name) -> -> arguments[arguments.length - 1] new Error "#{func_name} is not implemented"

Keybase = (@usernameOrEmail, @passphrase)->

Keybase.prototype._ensureLogin = (cb) ->
  return cb() unless not @session

  console.log "Not logged in, attempting to authorize"
  @login cb

Keybase.prototype.signup = (options, cb) ->
  passphrase = options.passphrase

  await @getsalt options.email, defer err, {salt}
  return cb err if err

  await util.gen_pwh {passphrase, salt}, defer err, pwh, salt, pwh_version
  return cb err if err

  options.salt = salt.toString('hex')
  options.pwh = pwh.toString('hex')
  options.pwh_version = pwh_version

  await request.post {
    url: API + '/signup.json'
    body: options
    json: true
  }, defer err, res, body

  cb err, body

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

  salt          = result.salt
  login_session = result.login_session

  await util.gen_hmac_pwh {@passphrase, salt, login_session}, defer err, hmac_pwh
  return cb err if err?

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

  options['session'] = options['session'] or @session
  options['csrf_token'] = options['csrf_token'] or @csrf_token

  await request.post {
    url: "#{API}/key/add.json"
    json: true
    body: options
  }, defer err, res, result

  cb err, result

Keybase.prototype.key_fetch = (options, cb) ->
  queryString = ''

  options['session'] = options['session'] or @session
  options['csrf_token'] = options['csrf_token'] or @csrf_token

  Object.keys(options).forEach (key) ->
    option = options[key]

    if queryString.length is 0
      queryString += '?'
    else
      queryString += '&'

    queryString += "#{key}="
    queryString += if Array.isArray(option) then option.join(',') else option

  await request.get {
    url: API + "/key/fetch.json#{queryString}"
    json: true
  }, defer err, res, body
  return cb err, body

Keybase.prototype.key_revoke = (options, cb) ->
  if arguments.length isnt 2
    cb = arguments[0]
    options = {}

  await @_ensureLogin defer err
  return cb err if err

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

Keybase.prototype.session_killall = (cb) ->
  await @_ensureLogin defer err
  return cb err if err

  options =
    csrf_token: @csrf_token
    session: @session

  # Unset current session
  @session = undefined
  @csrf_token = undefined

  await request.post {
    url: "#{API}/session/killall.json"
    json: true
    body: options
  }, defer err, res, result

  cb err, result

Keybase.prototype.sig_next_seqno = (options, cb) ->
  if arguments.length is 1
    cb = arguments[0]
    options = {}

  await @_ensureLogin defer err
  return cb err if err

  queryString = "?session=#{options["session"] or @session}&csrf_token=#{options["csrf_token"] or @csrf_token}&type=PUBLIC"

  await request.get {
    url: "#{API}/sig/next_seqno.json#{queryString}"
    json: true
  }, defer err, res, result

  cb err, result

Keybase.prototype.sig_post = noop "sig_post"

Keybase.prototype.sig_post_auth = noop "sig_post_auth"

Keybase.prototype.merkle_root = noop "merkle_root"

Keybase.prototype.merkle_block = noop "merkle_block"

module.exports = Keybase
