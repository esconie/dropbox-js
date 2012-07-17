express = require 'express'
open = require 'open'

# Tiny express.js server that handles the authorize callback.
class CallbackServer
  # Starts up a HTTP server.
  constructor: (@port = 8912) ->
    @callback = () -> null
    @createApp()

  # The callback URL that should be supplied to the OAuth /authorize call.
  url: ->
    "http://localhost:#{@port}/oauth_callback"

  # Returns a function that can be used as an OAuth driver.
  authDriver: ->
    (authUrl, callback) =>
      @openBrowser authUrl
      @callback = callback

  # Opens the given URL in a browser.
  openBrowser: (url) ->
    unless url.match /^https?:\/\//
      throw "Not a http/https URL: #{url}"
    open url

  # The server code.
  createApp: ->
    @app = express.createServer()
    @app.get '/oauth_callback', (request, response) =>
      @callback request.url
      @closeBrowser response
    @app.listen @port

  # Renders a response that will close the browser window used for OAuth.
  closeBrowser: (response) ->
    closeHtml = """
                <!doctype html>
                <script type="text/javascript">window.close();</script>
                <p>Please close this window.</p>
                """
    response.header 'Content-Type', 'text/html'
    response.send closeHtml

module.exports = new CallbackServer
