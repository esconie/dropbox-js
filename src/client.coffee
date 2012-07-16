# Represents a user accessing the application.
class DropboxClient
  # Dropbox client representing an application.
  #
  # For an optimal user experience, applications should use a single client for
  # all Dropbox interactions.
  #
  # @param {Object} options the application type and API key
  # @option {Boolean} sandbox true for applications that request sandbox access
  #     (access to a single directory exclusive to the app)
  # @option {String} key the application's API key
  # @option {String} secret the application's API secret
  constructor: (options) ->
    @sandbox = options.sandbox || false
    @apiKey = options.key
    @apiSecret = options.secret
    @reset()

  # Removes all login information.
  reset: ->
    @userId = null
    @token = null

  authenticate: (success, error) ->

  _request_token: ->

