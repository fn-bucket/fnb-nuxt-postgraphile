// const jwt = require('jsonwebtoken')
// const jwksClient = require('jwks-rsa')
import jwt from 'jsonwebtoken'
import jwksClient from 'jwks-rsa'

import { promisify }from 'util'
const jwtVerify = promisify(jwt.verify)

const jwksUri = process.env.JWKSURL
if (!jwksUri) {
  throw new Error('must define JWKSURL')
}

const client = jwksClient({
  cache: true,
  jwksUri: jwksUri,
})

function getKey(header: any, callback: any) {
  client.getSigningKey(header.kid, function (err: any, key: any) {
    if (err) {
      return callback(err)
    }
    var signingKey = key.publicKey || key.rsaPublicKey
    callback(null, signingKey)
  })
}

async function parseClaims(req: any) {
  try {
    const token = req.headers.authorization
      ? req.headers.authorization.split(' ')[1]
      : null

    if (!token) {
      throw 'No token provided'
    }
    return await jwtVerify(token, getKey, {})
  } catch (e: any) {
    if (e.toString() === 'No token provided') {
      throw e
    } else {
      throw new Error("SESSION EXPIRED")
    }
  }
}

export default parseClaims
