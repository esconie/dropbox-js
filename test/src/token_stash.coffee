# Stashes Dropbox access credentials.
class TokenStash
  constructor: ->
    @fs = require 'fs'
    @getCache = null
    @setupFs()

  # Calls the supplied method with the Dropbox access credentials.
  get: (callback) ->
    @getCache or= @readStash()
    if @getCache
      callback @getCache
      return null
    
    @liveLogin (credentials) =>
      unless credentials
        throw "Dropbox API authorization failed"

      @getCache = credentials
      @writeStash credentials
      callback @getCache

  # Obtains credentials by doing a login on the live site.
  liveLogin: (callback) ->
    Dropbox = require '../../lib/dropbox'
    client = new Dropbox.Client @clientOptions()
    @setupAuth()
    client.authDriver @authDriver.url(), @authDriver.authDriver()
    client.authenticate (data, error) =>
      @killAuth()
      credentials = @clientOptions()
      if error
        callback null
        return
      callback client.credentials()

  # Returns the options used to create a Dropbox Client.
  clientOptions: ->
    {
      key: 'h228j8rzh0hl0nb',
      secret: '3zvaj7tuopg6pg9'
    }


  # Reads the file containing the access credentials, if it is available.
  # 
  # @return {Object?} parsed access credentials, or null if they haven't been
  #     stashed
  readStash: ->
    unless @fs.existsSync @jsonPath
      return null
    JSON.parse @fs.readFileSync @jsonPath

  # Stashes the access credentials for future test use.
  writeStash: (credentials) ->
    json = JSON.stringify credentials
    @fs.writeFileSync @jsonPath, json

    js = "window.testKeys = #{json};"
    @fs.writeFileSync @jsPath, js

  # Sets up a node.js server-based authentication driver.
  setupAuth: ->
    return if @authDriver

    Dropbox = require '../../lib/dropbox'
    @authDriver = new Dropbox.Drivers.NodeServer
  
  # Shuts down the node.js server behind the authentication server.
  killAuth: ->
    return unless @authDriver
    
    @authDriver.closeServer()
    @authDriver = null

  # Sets up the directory structure for the credential stash.
  setupFs: ->
    @dirPath = 'test/.token'
    @jsonPath = 'test/.token/token.json'
    @jsPath = 'test/.token/token.js'

    unless @fs.existsSync @dirPath
      @fs.mkdirSync @dirPath

module.exports = TokenStash
