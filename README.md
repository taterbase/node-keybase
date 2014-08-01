![](http://progressed.io/bar/60)
#node-keybase

Keybase.io api library for Node.js


#Usage

`node-keybase` is just a 1-for-1 mapping to the [Keybase API](https://keybase.io/docs/api/1.0)

- [constructor](#constructor)
- [signup](#signup)
- [getsalt](#getsalt)
- [login](#login)
- [user/lookup](#userlookup)
- [user/autocomplete](#userautocomplete)
- [\<user\>/key.asc](#userkeyasc)
- [key/add](#keyadd)
- [key/fetch](#keyfetch)
- [key/revoke](#keyrevoke)
- [session/killall](#sessionkillall)
- [sig/next\_seqno](#signextseqno)
- [sig/post](#sigpost)
- [sig/post\_auth](#sigpostauth)
- [merkle/root](#merkleroot)
- [merkle/block](#merkleblock)


##constructor

`node-keybase` can be initialized with a username/email and passphrase for authentication or it can be passed in later `login`.

```javascript
var Keybase = require('node-keybase')
  , keybase = new Keybase(/* username_or_email, passphrase */)
```

## signup
[docs](https://keybase.io/docs/api/1.0/call/signup)

Signup through the api. (currently requires an invitation code)

```javascript
keybase.signup({
  name: "Lol",
  username: "lollerblades",
  email: "lollerblades@lollerblades.com",
  passphrase: "keep it secret keep it safe",
  invitation_id: "342128cecb14dbe6af0fab0d"
}, function(err, result) {})
```

Example Output
```javascript
{
  "status": {
      "code": 0
  },
  "csrf_token": "lgHZIDFjZmY0Nzlj..."  
}
```

## getsalt
[docs](https://keybase.io/docs/api/1.0/call/getsalt)

`getsalt` can have the username/email passed in or use the username/email that was passed in during initialization.

```javascript
keybase.getsalt(/* USERNAME_OR_EMAIL, */ function(err, result) {})
```

Example Output
```javascript
{
  "status": {
    "code": 0,
    "name": "OK"
  },
  "salt": "32355c2e7843513463263...",
  "csrf_token": "lgHZIDAxNzM1NzR...",
  "login_session": "lgHZIDhlY2I0..."
}
```

## login
[docs](https://keybase.io/docs/api/1.0/call/login)

`login` can have the username/email and passphrase passed in or use the values passed in during initialization.

```javascript
keybase.login(/* USERNAME_OR_EMAIL, PASSPHRASE, */ function(err, result) {})
```

Example Output
```javascript
{
"status": {
  "code": 0,
  "name": "OK"
},
 "session": "lgHZIDU1YzA3OWJmNWYx...",
 "me":      "/* {user object} */"
}
```

## user/lookup
[docs](https://keybase.io/docs/api/1.0/call/user/lookup)

You can look up users by `usernames`, `domain`, `twitter`, `github`, or `key`\_fingerprint. 

You can also specify which fields of the user objects you want in the result by specifying them in the `fields` option.

```javascript
keybase.user_lookup({
  usernames: ['max'],
  domain: ['keybase.io'],
  twitter: ['maxtaco'],
  key_fingerprint: ['94aa3a5bdbd40ea549cabaf9fbc07d6a97016cb3']
  fields: ['basics']
}, function(err, result) {})
```

Example Output
```javascript
// note that `them` is an array because certain lookups
// such as `domain` and `usernames` (which itself can be a list)
// can produce multiple results
{
  "status": {
    "code": 0,
    "name": "OK"
  },
  "them": [{
    "id": "9a2c8a8ac48162723c7992570c87da00",
    "basics": {
      "username": "maxtaco",
      "ctime": 1399919269,
      "mtime": 1399919269,
      "id_version": 5,
      "track_version": 1,
      "last_id_change": 1399919279
    },
    "pictures": {
      "primary": {
        "url": "https://s3.amazonaws.com/ke..._square_200.png",
        "width": 200,
        "height": 200
      }
    },
    "public_keys": {
      "primary": {
        "key_fingerprint": "e53878dbb0e644cff5f10e20fa9930221099dd13",
        "kid": "0101995d003...",
        "key_type": 1,
        "bundle": "-----BEGIN PGP PUBLIC KEY.../*cropped for display*/",
        "mtime": 1400074240,
        "ctime": 1400074240,
        "ukbid": "4f8bc40c19626b015308fcb9ef8c5811",
      }
    }
  }],
  "csrf_token": "lgHZIDQ1NTU0ODE3NzY5ZmM5N..."
}
```

## user/autocomplete
[docs](https://keybase.io/docs/api/1.0/call/user/autocomplete)

Fuzzy search for users

```javascript
keybase.user_autocomplete('max',  function(err, result){
})
```

Example Output
```javascript
{
  "status": {
    "code": 0,
    "name": "OK"
  },
  "completions": [
    {
      "total_score": 2,
      "components": {
        "username": {
          "val": "max",
          "score": 0
        },
        "key_fingerprint": {
          "val": "937b2cf047755301683ee3cfe19e4459d269c142",
          "score": 0
        },
        "full_name": {
          "val": "Max Krohn",
          "score": 0
        },
        "github": {
          "val": "maxtaco",
          "score": 1
        },
        "twitter": {
          "val": "maxtaco",
          "score": 1
        },
        "websites": [
          {
            "val": "oneshallpass.com",
            "score": 0,
            "protocol": "https:"
          },
          {
            "val": "keybase.io",
            "score": 0,
            "protocol": "https:"
          },
          {
            "val": "oneshallpass.com",
            "score": 0,
            "protocol": "dns"
          },
          {
            "val": "maxk.org",
            "score": 0,
            "protocol": "dns"
          }
        ]
      },
      "uid": "dbb165b7879fe7b1174df73bed0b9500",
      "thumbnail": "https://s3.amazonaws.com/key...f.jpeg",
      "is_followee": true
    }
  ],
  "csrf_token": "lgHZIDIzMjYwYzJjZTE5NDIwZjk3YjU4..."
}
```

## \<user\>/key.asc
[docs](https://keybase.io/docs/api/1.0/call/user/key.asc)

Get the Public Key for a Keybase user

```javascript
keybase.public_key_for_username('max', function(err, result){
})
```

Example Output
```
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG/MacGPG2 v2.0.22 (Darwin)
Comment: GPGTools - https://gpgtools.org

mQINBFJS084BEADG1jpg0YCEakf3VPbQTB8Sgthxh/SlisDcSsIqM33gjINJmWYz
6l8YbLRRfr0bNB1KSiEdCBbbx1eUZ6qlhbE+xXmpnxNkD3pauVyo5KMWMaDVgpDP
HcKH0hSiNmvR+DiOjn9dCQorx1rkB6NHkdKsVaEGPgdDuHTmQM9nRNw5/vTuyHkq
DBCFmYHsouCCDxBsEf0IQmIGabU3d8JWWnWbW1L1f9t/raaO9BIRv8WovsvJKGzw
PU5Qz9g0TQ3edl+tCPXEjj6RYOwGqy3d1LS73mRNTlCuOhwkvOMsfvKH5bwByeM4
60Ib/ZtKfpgop77ZTFyIPcP/YiToe5v2ts4Quwb8wy5akYr1aB4xzN/HucnJ8QGi
HYGNTCpyIIYHaomS4nAqnMhs4UWBE2WF/2rWKCTvWtd3m6jBUgcsP9eazJgUmgKj
hBEz9bsfcLPSH9lnfcj00AgEW8EF9bBNMAYc/BX4hAk0RRhh/dBf9ow4kRZBqgR/
c/f5nyOmCvQK7km5dz9jmMvMBIQZ4cqJP4NrEdRQh/xzio1wk40PKziZQwBlx1mS
iNPRgkeclwCaumxds9671gyHQjEGa7moPHfe/6zvduZ28yzbhq8ydZkfpq6YUrc8
GRtP/isXqlhSJ0dpsYA5njnIJE0GuhkNAYw7PUsLxQH0KP8Obu2ahnnu9wARAQAB
tCJDaHJpcyBDb3luZSA8Y2hyaXNAY2hyaXNjb3luZS5jb20+iQI+BBMBAgAoBQJS
UtPOAhsvBQkHhh+ABgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRD7wH1qlwFs
s6M7D/9UayLmZoIkNY266Wnl6wu5lcpxJ+c7v5/+VQEEmpI++D8HMURiHU+MXVFX
HxQEUm5KcoFDX81hl+G4KKlQlpcnX7QkkF7ZT9FFQj5SeKPkNmQxsqNhQNdfIboT
WcNmrQHcQu/EJRjFdWHpD5wKDFwIrsTNAiVzwMIue69MgDuw3xXJiF2xjM9GvWlI
CPiiOPTWoYCjhR3g0eYqyUTAuSfEkExDarKciBzOjGbOsUz5SjSqOu3GKQDAYhXd
UZ3VVEz+B5kxvggqs8WXo86vzYI1OvGO2N61JysQpnE6dtMmKKh91YYKoEKPY4iz
xSEssQLlCFJMU73eotlgqOwbsjsD/XoWCUvRKzAf4MuL3wsJcc5cdY6wk08GWk71
/Qm74jiAxqSGH/5znmPYfTCzvxcxm4Me9zEbRSmaZscDiZluaImJHErDNXH4CxPl
orP8yaEbTuqDVuJx5DEjnWemCVbN3u1U2FCjxloeV5aOdH3jhlMrCY5mO6rw8Vh/
DI1zro3A7/PJ+tCsj3luJwhthD4TLmZlQqeAqaZ6gNinVGNwSeQT9num0DBUPBtQ
ky44+lS810RL54YxfZ1fMaLCNdVDXaepuCbyusHSBA0Cq1tNioFai1eT
=MqTh
-----END PGP PUBLIC KEY BLOCK-----
```

## key/add
**NOTICE:** Does not support private keys yet

[docs](https://keybase.io/docs/api/1.0/call/key/add)

Add a public/private key. See docs for acceptable key formats and order of uploading.

```javascript
keybase.key_add({
  public_key: PUBLIC_KEY,
  private_key: PRIVATE_KEY,
  is_primary: true //set as primary key
}, function(err, result){})
```

Example Output
```javascript
{
  "status": {
    "code": 0,
    "name": "OK"
  },
  "kid":            "0101d9d962be6ee38cdadedd6...",
  "csrf_token":     "lgHZIDU1YzA3OWJmNWYxNjUwZ...",
  "is_primary":     true
}
```

## key/fetch
**NOTICE:** Does not support fetching private keys yet

[docs](https://keybase.io/docs/api/1.0/call/key/fetch)

Fetch a public/private key. See docs for more info.

```javascript
keybase.key_fetch({pgp_key_ids: ['6052b2ad31a6631c', '980A3F0D01FE04DF'], ops: 1}, function(err, result){})
```

Example Output
```javascript
{
  "status": {
    "code": 0,
    "name": "OK"
  },
  "keys": [
    {
      "bundle": "-----BEGIN PGP PUBLIC KEY BLOCK----- ..."
      "uid": "dbb165b7879fe7b1174df73bed0b9500",
      "username": "max",
      "key_type": 1,
      "kid": "01013ef90b4c4e62121d12a51d18569b57996002c8bdccc9b2740935c9e4a07d20b40a",
      "self_signed": 1,
      "primary_bundle_in_keyring": 1,
      "self_sign_type": 1,
      "subkeys": {
        "6052b2ad31a6631c": {
          "flags": 47,
          "is_primary": 1
        },
        "980a3f0d01fe04df": {
          "flags": 46,
          "is_primary": 0
        }
      },
      "secret": 0
    }
  ]
}
```

## key/revoke
[docs](https://keybase.io/docs/api/1.0/call/key/revoke)

Revoke a public/private key. if no `kid` is specified the primary key is revoked.

```javascript
keybase.key_revoke(/* {kid: KEY_ID}, */ function(err, result){})
```

Example Output
```javascript
{
  "status": {
    "code": 0,
    "name": "OK"
  },
  "csrf_token": "lgHZIDU1YzA3OWJmNWYxNjUwZ..."
}
```

## session/killall
[docs](https://keybase.io/docs/api/1.0/call/session/killall)

Kill all active sessions for user.

```javascript
keybase.session_killall(function(err, result){})
```

Example Output
```javascript
{
  "status": {
    "code": 0,
    "name": "OK"
  },
  "csrf_token": "lgHZIDU1YzA3OWJmNWYxNjUwZ..."
}
```

## sig/next\_seqno
[docs](https://keybase.io/docs/api/1.0/call/sig/next_seqno)

Get the next sequence number in the user's signature chain, returning also the hash of the previous block.

```javascript
keybase.sig_next_seqno(function(err, result){})
```

Example Output
```javascript
{
  "status": {
    "code": 0,
    "name": "OK"
  },
  "prev":       "c450220f5235fcb646a66dfb4225dd65...",
  "seqno": 2,
  "csrf_token": "lgHZIDVhMjYwOTQ3OTM5OGNhODljYzRh..."
}
```

## sig/post
[docs](https://keybase.io/docs/api/1.0/call/sig/post)

*Not implemented*

Example Output
```javascript
{
   "status" : {
      "code" : 0,
      "name" : "OK"
   },
  "proof_text": "Verifying myself: I am maxtaco on Key...",
  "sig_id": "2232c5e872bce853606daae410ea3516999539c79...",
  "proof_id": "24be5e265b1ff1be02a70310",
  "payload_hash": "c450220f5235fcb646a66dfb4225dd65334...",
  "csrf_token": "lgHZIDVhMjYwOTQ3OTM5OGNhODljYzRhNzQ1M..."
}
```

## sig/post\_auth
[docs](https://keybase.io/docs/api/1.0/call/sig/post_auth)

*Not implemented*

Example Output
```javascript
{
  "status": {
    "code": 0,
    "name": "OK"
  }
  "auth_token" : "fd2667b9b396150603ea0b567eaf3334c3..."
}
```

## merkle/root
[docs](https://keybase.io/docs/api/1.0/call/merkle/root)

*Not implemented*

Example Output
```javascript
{
  "status": {
    "code": 0,
    "name": "OK"
  },
  "hash": "803b4d2024952280c1cc10f408596951b5d23e...",
  "seqno": 1052,
  "ctime_string": "2014-04-27T12:46:05.000Z",
  "ctime": 1398602765,
  "sig": "-----BEGIN PGP MESSAGE-----
Version: GnuPG...",
  "payload_json": "{"body":{"key":{"fingerprint":"03...",
  "txid": "49fde49b575382954b42920d91057915"
}
```

## merkle/block
[docs](https://keybase.io/docs/api/1.0/call/merkle/block)

*Not implemented*

Example Output
```javascript
{
  "status": {
    "code": 0,
    "name": "OK"
  },
  "hash": "c9e6dd2ead7218258fffa150b...",
  "value": {
    "tab": {
      "00": "d70b05a791acae2c6072d5bf3086b26...",
      "01": "92a4ff6f918d257f06f1eb5c296d86e...",
      "02": "2a7d1e7e3cafed7146eebf0d60c0d05...",
      "03": "12e4e169bcbe0a42500677902a95c95...",
      "04": "6e57ba5f779aa825762d1da47de4879...",
      "05": "02ad26b594b431b0bd331781065350d...",
      "06": "119e58ac656977c5d2edc296d5ca17c...",
      "07": "cc2e1ae9a976a5fc824a258d4c006ab...",
      ...
    },
    "type": 1
  },
  "value_string": "{\"tab\":{\"00\":\"d70b05a...\"}"
  "ctime": "2014-04-23T21:29:33.000Z",
  "type": 1
}
```
