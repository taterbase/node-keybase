USERNAME_OR_EMAIL = process.env['KEYBASE_USERNAME_OR_EMAIL']
PASSPHRASE = process.env['KEYBASE_PASSPHRASE']

PUBLIC_KEY = process.env['KEYBASE_PUBLIC_KEY'] or require './publickey'
PRIVATE_KEY = process.env['KEYBASE_PRIVATE_KEY'] or require './privatekey'

Keybase = require '../'
keybase = new Keybase USERNAME_OR_EMAIL, PASSPHRASE

add_public_key = (cb) ->
  keybase.key_add {
    public_key: PUBLIC_KEY
    is_primary: true
  }, cb

describe 'node-keybase', ->

  @timeout 3000

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

  it 'should authorize passed in creds', (done) ->
    await keybase.authorize USERNAME_OR_EMAIL, PASSPHRASE, defer err, result
    return done err if err

    result.guest_id.should.be.ok
    result.session.should.be.ok
    result.uid.should.be.ok
    result.me.should.be.ok
    result.csrf_token.should.be.ok

    done()

  it 'should authorize with initialized in creds', (done) ->
    await keybase.authorize defer err, result
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

  it 'should allow you to fetch keys', (done) ->
    keybase.key_fetch {}, done

  it 'should allow you to revoke the primary key', (done) ->
    @timeout 5000

    await add_public_key defer err, result
    return done err if err

    await keybase.key_revoke defer err, result
    return done err if err

    result.status.name.should.equal 'OK'
    result.revocation_id.should.be.ok

    done()

  it 'should allow you to revoke a key by kid', (done) ->
    @timeout 5000

    await add_public_key defer err, result
    return done err if err

    kid = result.kid

    await keybase.key_revoke {kid}, defer err, result
    return done err if err

    result.status.name.should.equal 'OK'
    result.revocation_id.should.be.ok

    done()
