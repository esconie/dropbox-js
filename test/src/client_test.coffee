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

      client.apiServer.should.equal(
        'https://api.sandbox.dropbox-proxy.com')
      client.authServer.should.equal(
        'https://www.sandbox.dropbox-proxy.com')
      client.fileServer.should.equal(
        'https://api-content.sandbox.dropbox-proxy.com')

  describe 'authenticate', ->
    it 'completes the flow', (done) ->
      @timeout 120 * 1000  # Time-consuming because the user must click.
      @client.authenticate (uid, error) ->
        assert.ok uid
        done()

  describe 'getFiles', ->
    it 'gets a file', (done) ->
      @timeout 120 * 1000
      client = @client
      @client.authenticate (uid, error) ->
        assert.ok uid
        client.getFiles 'dropbox', 'api-test.txt', undefined, (file, err) ->
            file.should.equal "This is the api secret\n"
            done()

  describe 'putFiles', ->
    it 'puta a file', (done) ->
      @timeout 120*1000
      client = @client
      @client.authenticate (uid, error) ->
        assert.ok uid
        client.putFiles 'dropbox', 'api-write-test.txt', 'This is not the api secret', undefined, true, undefined, (metadata, error) ->
            metadata = JSON.parse(metadata)
            metadata.path.should.equal "/api-write-test.txt"
            done()
