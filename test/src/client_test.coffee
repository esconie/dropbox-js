describe 'DropboxClient', ->
  beforeEach ->
    @client = new Dropbox.Client
      key: testKeys.key,
      secret: testKeys.secret
    @client.authDriver authDriverUrl, authDriver
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
      @timeout 15 * 1000  # Time-consuming because the user must click.
      @client.authenticate (uid, error) ->
        expect(uid).to.be.a 'string'
        done()

  describe 'getFiles', ->
    it 'gets a file', (done) ->
      @timeout 120 * 1000
      client = @client
      @client.authenticate (uid, error) ->
        assert.ok uid
        client.getFiles 'dropbox', 'api-test.txt', undefined, (file, err) ->
            expect(file).to.equal "This is the api secret\n"
            done()

  describe 'putFiles', ->
    it 'puta a file', (done) ->
      @timeout 120*1000
      client = @client
      @client.authenticate (uid, error) ->
        assert.ok uid
        client.putFiles 'dropbox', 'api-write-test.txt', 'This is not the api secret', undefined, true, undefined, (metadata, error) ->
            metadata = JSON.parse(metadata)
            expect(metadata.path).to.equal "/api-write-test.txt"
            done()

  describe 'metadata', ->
    it 'retrieves file metadata', (done) ->
      @timeout 120*1000
      client = @client
      @client.authenticate (uid, error) ->
        assert.ok uid
        client.metadata 'dropbox', 'api-test.txt', undefined, undefined, undefined, undefined, undefined, undefined, (metadata, error) ->
            metadata = JSON.parse(metadata)
            expect(metadata.path).to.equal "/api-test.txt"
            done()
