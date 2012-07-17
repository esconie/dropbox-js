# OAuth driver that uses a popup window and postMessage to complete the flow.
class DropboxPopupDriver
  constructor: ->
    @computeUrl()

  # Builds a function that can be used as an OAuth driver by Dropbox.Client.
  #
  # @return {function(String, function(String))} function that can be passed to
  #     authDriver on Dropbox.Client.
  authDriver: ->
    (authUrl, callback) =>
      @listenForMessage callback
      @openWindow authUrl

  # The URL of the HTML file that can receive OAuth redirects.
  #
  # @return {String} an URL
  url: ->
    @receiverUrl

  # Pre-computes the return value of url.
  computeUrl: ->
    fragments = window.location.toString().split '/'
    fragments[fragments.length - 1] = 'oauth_receiver.html'
    @receiverUrl = fragments.join('/') + '#'

  # Creates a popup window.
  #
  # @param {String} url the URL that will be loaded in the popup window
  openWindow: (url) ->
    window.open url, '_dropboxOauthSigninWindow', @popupWindowSpec(980, 980)

  # Spec string for window.open to create a nice popup.
  #
  # @param {Number} popupWidth the desired width of the popup window
  # @param {Number} popupHeight the desired height of the popup window
  # @return {String} spec string for the popup window
  popupWindowSpec: (popupWidth, popupHeight) ->
    # Metrics for the current browser window.
    x0 = window.screenX ? window.screenLeft
    y0 = window.screenY ? window.screenTop
    width = window.outerWidth ? document.documentElement.clientWidth
    height = window.outerHeight ? document.documentElement.clientHeight

    # Computed popup window metrics.
    popupLeft = Math.round x0 + (width - popupWidth) / 2
    popupTop = Math.round y0 + (height - popupHeight) / 2.5

    # The specification string.
    "width=#{popupWidth},height=#{popupHeight}," +
      "left=#{popupLeft},top=#{popupTop}" +
      'dialog=yes,dependent=yes,scrollbars=yes,location=yes'

  # Listens for a postMessage from a previously opened popup window.
  #
  # @param {function(Object)} called when the message is received
  listenForMessage: (callback) ->
    listener = (event) ->
      callback event.data
      window.removeEventListener 'message', listener
    window.addEventListener 'message', listener, false


# OAuth driver that redirects the browser to a node app to complete the flow.
#
# This is useful for testing node.js libraries and applications.
class DropboxNodeServerDriver
  # Starts up the node app that intercepts the browser redirect.
  #
  # @param {Number} port the port number to listen to for requests
  constructor: (@port = 8912) ->
    # Calling require in the constructor because this doesn't work in browsers.
    @open = require 'open'
    @http = require 'http'
    
    @callback = () -> null
    @urlRe = new RegExp "^/oauth_callback\?"
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
    @open url

  # Creates and starts up an HTTP server that will intercept the redirect.
  createApp: ->
    @app = @http.createServer (request, response) =>
      @doRequest request, response
    @app.listen @port

  # Shuts down the HTTP server.
  #
  # The driver will become unusable after this call.
  closeServer: ->
    @app.close()

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
