describe 'DropboxClient', ->
  beforeEach ->
    @client = new Dropbox.Client
      key: testKeys.key,
      secret: testKeys.secret
    @client.authDriver callbackServer.url(), (authUrl, callback) ->
      callbackServer.openBrowser authUrl
      callbackServer.callback = callback

  describe 'custom API server', ->
    it 'computes the other URLs correctly', ->
      client = new Dropbox.Client
        key: testKeys.key,
        secret: testKeys.secret,
        server: 'https://api.sandbox.dropbox-proxy.com'

      expect(client.apiServer).to.equal(
        'https://api.sandbox.dropbox-proxy.com')
      expect(client.authServer).to.equal(
        'https://www.sandbox.dropbox-proxy.com')
      expect(client.fileServer).to.equal(
        'https://api-content.sandbox.dropbox-proxy.com')

  describe 'authenticate', ->
    it 'completes the flow', (done) ->
      @timeout 120 * 1000  # Time-consuming because the user must click.
      @client.authenticate (uid, error) ->
        expect(uid).to.be.a 'string'
        done()
