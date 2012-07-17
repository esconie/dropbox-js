http = require 'http'
open = require 'open'

# Tiny node.js server that handles the authorize callback.
class CallbackServer
  # Starts up a HTTP server.
  constructor: (@port = 8912) ->
    @callback = () -> null
    @urlRe = new RegExp "^/oauth_callback\?"

    @http = http.createServer (request, response) =>
      @doRequest request, response
    @http.listen @port

  # The callback URL that should be supplied to the OAuth /authorize call.
  url: ->
    "http://localhost:#{@port}/oauth_callback"

  # Opens the given URL in a browser.
  openBrowser: (url) ->
    unless url.match /^https?:\/\//
      throw "Not a http/https URL: #{url}"
    open url

  # Reads out an /authorize callback.
  doRequest: (request, response) ->
    if @urlRe.exec request.url
      @callback request.url
    data = ''
    request.on 'data', (dataFragment) -> data += dataFragment
    request.on 'end', =>
      @closeBrowser response

  # Renders a response that will close the browser window used for OAuth.
  closeBrowser: (response) ->
    closeHtml = """
                <!doctype html>
                <script type="text/javascript">window.close();</script>
                <p>Please close this window.</p>
                """
    response.writeHead(200,
      {'Content-Length': closeHtml.length, 'Content-Type': 'text/html' })
    response.write closeHtml
    response.end

module.exports = new CallbackServer
