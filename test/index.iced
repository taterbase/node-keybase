USERNAME_OR_EMAIL = process.env['KEYBASE_USERNAME_OR_EMAIL']
PASSPHRASE = process.env['KEYBASE_PASSPHRASE']

keybase = require '../'

describe 'node-keybase', ->

  before ->
    this.timeout 3000

  it 'should get salt', (done) ->
    await keybase.getsalt USERNAME_OR_EMAIL, defer err, result
    return done err if err

    result.guest_id.should.be.ok
    result.salt.should.be.ok
    result.login_session.should.be.ok
    result.pwh_version.should.be.ok
    result.csrf_token.should.be.ok

    done()

  it 'should authorize', (done) ->
    await keybase.authorize USERNAME_OR_EMAIL, PASSPHRASE, defer err, result
    return done err if err

    result.guest_id.should.be.ok
    result.session.should.be.ok
    result.uid.should.be.ok
    result.me.should.be.ok
    result.csrf_token.should.be.ok

    done()

  it 'should find users', (done) ->
    await keybase.user_lookup {
      github: 'taterbase',
      fields: ['basics']
    }, defer err, result
    return done err if err

    result.them.should.be.ok
    result.them.length.should.equal 1
    result.them[0].basics.should.be.ok

    done()

  it 'should use autocomplete', (done) ->
    await keybase.user_autocomplete 'tater', defer err, result
    return done err if err

    result.completions.should.be.ok

    done()
