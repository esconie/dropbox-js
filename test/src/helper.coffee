if global? and require? and module?
  # Node.JS
  exports = global

  global.Dropbox = require '../../lib/dropbox'
  global.chai = require 'chai'
  global.sinon = require 'sinon'
  global.sinonChai = require 'sinon-chai'
  
  authDriver = new Dropbox.Drivers.NodeServer()

  TokenStash = require './token_stash.js'
  (new TokenStash()).get (credentials) ->
    global.testKeys = credentials
else
  # Browser
  exports = window
  
  # TODO: figure out authentication without popups
  authDriver = new Dropbox.Drivers.Popup()


# Common setup
exports.assert = exports.chai.assert
exports.expect = exports.chai.expect
exports.authDriverUrl = authDriver.url()
exports.authDriver = authDriver.authDriver()
