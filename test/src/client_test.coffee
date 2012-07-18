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

  describe 'fileopsCreateFolder', ->
    it 'creates a folder', (done) ->
      @timeout 120*1000
      client = @client
      @folderName = folderName = "jsapi-tests" + Math.random().toString(36)
      @client.authenticate (uid, error) ->
        assert.ok uid
        client.fileopsCreateFolder 'dropbox', folderName, undefined, (metadata, error) ->
            metadata = JSON.parse(metadata)
            expect(metadata.path).to.equal "/#{folderName}"
            done()

  describe 'putFiles', ->
    it 'puta a file', (done) ->
      @timeout 120*1000
      client = @client
      filePath = "#{@folderName}/api-test.txt"
      @client.authenticate (uid, error) ->
        assert.ok uid
        client.putFiles 'dropbox', filePath, 'This is not the api secret', undefined, true, undefined, (metadata, error) ->
            metadata = JSON.parse(metadata)
            expect(metadata.path).to.equal "/#{filePath}"
            done()

  describe 'getFiles', ->
    it 'gets a file', (done) ->
      @timeout 120 * 1000
      client = @client
      filePath = "#{@folderName}/api-test.txt"
      @client.authenticate (uid, error) ->
        assert.ok uid
        client.getFiles 'dropbox', filePath, undefined, (file, err) ->
            expect(file).to.equal "This is not the api secret"
            done()

  describe 'metadata', ->
    it 'retrieves file metadata', (done) ->
      @timeout 120*1000
      client = @client
      filePath = "#{@folderName}/api-test.txt"
      @client.authenticate (uid, error) ->
        assert.ok uid
        client.metadata 'dropbox', filePath, undefined, undefined, undefined, undefined, undefined, undefined, (metadata, error) ->
            metadata = JSON.parse(metadata)
            expect(metadata.path).to.equal "/#{filePath}"
            done()

  describe 'revisions', ->
    it 'gets a list of revisions', (done) ->
      @timeout 120*1000
      client = @client
      filePath = "#{@folderName}/api-test.txt"
      @client.authenticate (uid, error) ->
        assert.ok uid
        client.revisions 'dropbox', filePath, undefined, undefined, (metadata, error) ->
            metadata = JSON.parse(metadata)
            expect(metadata.length).to.equal 1
            done()

  describe 'delta', ->
    it 'gets a list of changes', (done) ->
      @timeout 120*1000
      client = @client
      @client.authenticate (uid, error) ->
        assert.ok uid
        client.delta undefined, undefined, (metadata, error) ->
            metadata = JSON.parse(metadata)
            done()

  describe 'restore', ->
    it 'restores a file (deletes it first)', (done) ->
      @timeout 120*1000
      client = @client
      filePath = "#{@folderName}/api-test.txt"
      @client.authenticate (uid, error) ->
        assert.ok uid
        client.fileopsDelete 'dropbox', filePath, undefined, (metadata, error) ->
            metadata = JSON.parse(metadata)
            expect(metadata.path).to.equal "/#{filePath}"
            done()

  describe 'revisions', ->
    it 'gets a list of revisions', (done) ->
      @timeout 120*1000
      client = @client
      filePath = "#{@folderName}/api-test.txt"
      @client.authenticate (uid, error) ->
        assert.ok uid
        client.revisions 'dropbox', filePath, undefined, undefined, (metadata, error) ->
            metadata = JSON.parse(metadata)
            rev = metadata[1].rev
            client.restore 'dropbox', filePath, rev, undefined, (metadata, error) ->
                metadata = JSON.parse(metadata)
                expect(metadata.path).to.equal "/#{filePath}"
                done()

  describe 'search', ->
    it 'searches for files', (done) ->
      @timeout 120*1000
      client = @client
      folderName = @folderName
      @client.authenticate (uid, error) ->
        assert.ok uid
        client.search 'dropbox', '', folderName, undefined, undefined, undefined, (metadata, error) ->
            metadata = JSON.parse(metadata)
            expect(metadata.length).to.equal 1
            done()

  describe 'shares', ->
    it 'returns a dropbox link', (done) ->
      @timeout 120*1000
      client = @client
      filePath = "#{@folderName}/api-test.txt"
      @client.authenticate (uid, error) ->
        assert.ok uid
        client.shares 'dropbox', filePath, undefined, undefined, (metadata, error) ->
            metadata = JSON.parse(metadata)
            expect(metadata.url).to.be.ok
            done()

  describe 'media', ->
    it 'gets a streamable link', (done) ->
      @timeout 120*1000
      client = @client
      filePath = "#{@folderName}/api-test.txt"
      @client.authenticate (uid, error) ->
        assert.ok uid
        client.media 'dropbox', filePath, undefined, (metadata, error) ->
            metadata = JSON.parse(metadata)
            expect(metadata.url).to.be.ok
            done()

  describe 'fileopsCopy', ->
    it 'copies a file', (done) ->
        @timeout 120*1000
        client = @client
        filePath = "#{@folderName}/api-test.txt"
        @client.authenticate (uid, error) ->
          assert.ok uid
          client.fileopsCopy 'dropbox', filePath, "#{filePath}_copy", undefined, undefined, (metadata, error) ->
              metadata = JSON.parse(metadata)
              expect(metadata.path).to.equal "/#{filePath}_copy"
              done()

  describe 'fileopsMove', ->
    it 'moves a file', (done) ->
        @timeout 120*1000
        client = @client
        filePath = "#{@folderName}/api-test.txt"
        @client.authenticate (uid, error) ->
          assert.ok uid
          client.fileopsMove 'dropbox', filePath, "#{filePath}_copy2", undefined, (metadata, error) ->
              metadata = JSON.parse(metadata)
              expect(metadata.path).to.equal "/#{filePath}_copy2"
              done()


  describe 'fileopsDelete', ->
    it 'deletes a folder', (done) ->
        @timeout 120*1000
        client = @client
        folderName = @folderName
        @client.authenticate (uid, error) ->
          assert.ok uid
          client.fileopsDelete 'dropbox', folderName, undefined, (metadata, error) ->
              metadata = JSON.parse(metadata)
              expect(metadata.path).to.equal "/#{folderName}"
              done()

