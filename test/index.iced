USERNAME_OR_EMAIL = process.env['KEYBASE_USERNAME_OR_EMAIL']
PASSPHRASE = process.env['KEYBASE_PASSPHRASE']

PUBLIC_KEY = process.env['KEYBASE_PUBLIC_KEY'] or require './publickey'
PRIVATE_KEY = process.env['KEYBASE_PRIVATE_KEY'] or require './privatekey'

Keybase = require '../'
keybase = new Keybase USERNAME_OR_EMAIL, PASSPHRASE
util = require '../util'

add_public_key = (cb) ->
  keybase.key_add {
    public_key: PUBLIC_KEY
    is_primary: true
  }, cb

describe 'node-keybase', ->

  @timeout 9000

  it 'should allow a user to sign up', (done) ->
    options =
      name: "Lol"
      username: "lollerblades"
      email: "lollerblades@lollerblades.com"
      passphrase: "keep it secret keep it safe"
      invitation_id: "342128cecb14dbe6af0fab0d"

    await keybase.signup options, defer err, result

    result.status.code.should.equal 707
    result.status.name.should.equal "BAD_INVITATION_CODE"
    result.guest_id.should.be.ok
    result.csrf_token.should.be.ok

    done err

  it 'should get salt with passed in creds', (done) ->
    await keybase.getsalt USERNAME_OR_EMAIL, defer err, result
    return done err if err

    result.guest_id.should.be.ok
    result.salt.should.be.ok
    result.login_session.should.be.ok
    result.pwh_version.should.be.ok
    result.csrf_token.should.be.ok

    done()

  it 'should get salt with initialized creds', (done) ->
    await keybase.getsalt defer err, result
    return done err if err

    result.guest_id.should.be.ok
    result.salt.should.be.ok
    result.login_session.should.be.ok
    result.pwh_version.should.be.ok
    result.csrf_token.should.be.ok

    done()

  it 'should login with passed in creds', (done) ->
    await keybase.login USERNAME_OR_EMAIL, PASSPHRASE, defer err, result
    return done err if err

    result.guest_id.should.be.ok
    result.session.should.be.ok
    result.uid.should.be.ok
    result.me.should.be.ok
    result.csrf_token.should.be.ok

    done()

  it 'should login with initialized in creds', (done) ->
    await keybase.login defer err, result
    return done err if err

    result.guest_id.should.be.ok
    result.session.should.be.ok
    result.uid.should.be.ok
    result.me.should.be.ok
    result.csrf_token.should.be.ok

    done()

  it 'should find users', (done) ->
    await keybase.user_lookup {
      usernames: ['testing'],
      fields: ['basics']
    }, defer err, result
    return done err if err

    result.them.should.be.ok
    result.them.length.should.equal 1
    result.them[0].basics.should.be.ok

    done()

  it 'should use autocomplete', (done) ->
    await keybase.user_autocomplete 'testing', defer err, result
    return done err if err

    result.completions.should.be.ok

    done()

  it 'should grab the public key for a user', (done) ->
    await keybase.public_key_for_username 'testing', defer err, result
    return done err if err

    result.should.be.ok
    (typeof result).should.equal 'string'

    done()

  it 'should allow you to add a public key', (done) ->
    await add_public_key defer err, result
    return done err if err

    result.status.name.should.equal "OK"

    done()

  # TODO: We need a clean way to generate a p3skb to test this functionality
  it 'should allow you to add a private key'

  it 'should allow you to fetch public keys', (done) ->
    await keybase.key_fetch {pgp_key_ids: ['6052b2ad31a6631c', '980A3F0D01FE04DF'], ops: 1}, defer err, result
    return done err if err

    result.status.name.should.equal 'OK'
    result.keys.should.be.ok
    result.keys.length.should.equal 2

    done()

  # TODO: need to be able upload private keys first
  it 'should allow you to fetch private keys'

  it 'should allow you to revoke the primary key', (done) ->
    await add_public_key defer err, result
    return done err if err

    await keybase.key_revoke defer err, result
    return done err if err

    result.status.name.should.equal 'OK'
    result.revocation_id.should.be.ok

    done()

  it 'should allow you to revoke a key by kid', (done) ->
    await add_public_key defer err, result
    return done err if err

    kid = result.kid

    await keybase.key_revoke {kid}, defer err, result
    return done err if err

    result.status.name.should.equal 'OK'
    result.revocation_id.should.be.ok

    done()

  it 'should kill all sessions', (done) ->
    await keybase.session_killall defer err, result
    return done err if err

    result.status.name.should.equal 'OK'

    done()

  after (done) ->
    # We have to make sure this test runs by itself to function correctly

    # it "should get the next sequence number in the user's signature chain", (done) ->
    await keybase.key_revoke defer err, result
    return done err if err

    await add_public_key defer err, result
    return done err if err

    await keybase.sig_next_seqno defer err, result
    return done err if err

    result.status.name.should.equal 'OK'

    done()

  it 'should allow signature posting'

  it 'should allow authentication via signing a message'

  it 'return the current site-wide Merkle root hash'

  it 'should, given a hash, lookup the block that hashes to it'

describe 'keybase-utils', ->

  it "should be able to generate a key"
  #  username = 'lol'
  #  passphrase = 'lolagain'

  #  await util.gen_key {username, passphrase}, defer err
  #  done err
