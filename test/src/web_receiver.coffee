# Logic for showing a popup window and waiting for a postMessage from it.
class WebReceiver
  constructor: ->
    @computeUrl()

  # Returns a function that can be used as an OAuth driver.
  authDriver: ->
    (authUrl, callback) =>
      @listenForMessage callback
      @openWindow authUrl

  # The URL of the HTML file that can receive OAuth redirects.
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


window.webReceiver = new WebReceiver()
