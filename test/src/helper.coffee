if global? and require? and module?
  # Node.JS
  exports = global

  global.Dropbox = require '../../lib/dropbox'
  global.chai = require 'chai'
  global.sinon = require 'sinon'
  global.sinonChai = require 'sinon-chai'
  global.callbackServer = require './callback_server'

else
  # Browser
  exports = window


# Common setup
exports.assert = exports.chai.assert
exports.expect = exports.chai.expect


# TODO: read this from some file
exports.testKeys =
  key: 'h228j8rzh0hl0nb',
  secret: '3zvaj7tuopg6pg9'
