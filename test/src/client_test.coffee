describe 'DropboxClient', ->
  beforeEach ->
    @client = new Dropbox.Client testKeys

  describe 'URLs for custom API server', ->
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

  describe 'normalizePath', ->
    it "doesn't touch relative paths", ->
      expect(@client.normalizePath('aa/b/cc/dd')).to.equal 'aa/b/cc/dd'

    it 'removes the leading / from absolute paths', ->
      expect(@client.normalizePath('/aaa/b/cc/dd')).to.equal 'aaa/b/cc/dd'

  describe 'authenticate', ->
    it 'completes the flow', (done) ->
      @timeout 15 * 1000  # Time-consuming because the user must click.
      @client.reset()
      @client.authDriver authDriverUrl, authDriver
      @client.authenticate (uid, error) ->
        expect(uid).to.be.a 'string'
        done()

  describe 'fileopsCreateFolder', ->
    it 'creates a folder', (done) ->
      @folderName = '/jsapi-tests' + Math.random().toString(36)
      @client.fileopsCreateFolder @folderName, undefined, (metadata, error) =>
        expect(error).not.to.be.ok
        metadata = JSON.parse metadata
        expect(metadata.path).to.equal @folderName
        done()

  describe 'writeFile', ->
    it 'writes a file to Dropbox', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      contents = "This is the api secret\n"
      @client.writeFile filePath, contents, (metadata, error) ->
        expect(error).to.not.be.ok
        metadata = JSON.parse metadata
        expect(metadata.path).to.equal filePath
        done() 

  describe 'readFile', ->
    it 'reads a file from Dropbox', (done) ->
      contents = "This is the api secret\n"
      @client.readFile 'api-test.txt', (data, error) ->
        expect(error).to.not.be.ok
        expect(data).to.equal contents
        done()

  describe 'metadata', ->
    it 'retrieves file metadata', (done) ->
      @client.metadata 'api-test.txt', undefined, undefined, undefined, undefined, undefined, undefined, (metadata, error) ->
        expect(error).not.to.be.ok
        metadata = JSON.parse(metadata)
        expect(metadata.path).to.equal '/api-test.txt'
        done()

  describe 'revisions', ->
    it 'gets a list of revisions', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      @client.revisions filePath, undefined, undefined, (metadata, error) ->
        expect(error).not.to.be.ok
        metadata = JSON.parse(metadata)
        expect(metadata.length).to.equal 1
        done()

  describe 'delta', ->
    it 'gets a list of changes', (done) ->
      @client.delta undefined, undefined, (metadata, error) ->
        expect(error).not.to.be.ok
        metadata = JSON.parse(metadata)
        done()

  describe 'restore', ->
    it 'restores a file (deletes it first)', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      @client.fileopsDelete filePath, undefined, (metadata, error) ->
        expect(error).not.to.be.ok
        metadata = JSON.parse(metadata)
        expect(metadata.path).to.equal filePath
        done()

  describe 'revisions', ->
    it 'gets a list of revisions', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      @client.revisions filePath, undefined, undefined, (metadata, error) =>
        expect(error).not.to.be.ok
        metadata = JSON.parse(metadata)
        rev = metadata[1].rev
        @client.restore filePath, rev, undefined, (metadata, error) ->
          metadata = JSON.parse(metadata)
          expect(metadata.path).to.equal filePath
          done()

  describe 'search', ->
    it 'searches for files', (done) ->
      folderName = @folderName.substring 1
      @client.search '/', folderName, undefined, undefined, undefined, (metadata, error) ->
        expect(error).not.to.be.ok
        metadata = JSON.parse(metadata)
        expect(metadata.length).to.equal 1
        done()

  describe 'shares', ->
    it 'returns a dropbox link', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      @client.shares filePath, undefined, undefined, (metadata, error) ->
        expect(error).not.to.be.ok
        metadata = JSON.parse(metadata)
        expect(metadata.url).to.be.ok
        done()

  describe 'media', ->
    it 'gets a streamable link', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      @client.media filePath, undefined, (metadata, error) ->
        expect(error).not.to.be.ok
        metadata = JSON.parse(metadata)
        expect(metadata.url).to.be.ok
        done()

  describe 'fileopsCopy', ->
    it 'copies a file', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      @client.fileopsCopy filePath, "#{filePath}_copy", undefined, undefined, (metadata, error) ->
        expect(error).not.to.be.ok
        metadata = JSON.parse(metadata)
        expect(metadata.path).to.equal "#{filePath}_copy"
        done()

  describe 'fileopsMove', ->
    it 'moves a file', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      @client.fileopsMove filePath, "#{filePath}_copy2", undefined, (metadata, error) ->
        expect(error).not.to.be.ok
        metadata = JSON.parse(metadata)
        expect(metadata.path).to.equal "#{filePath}_copy2"
        done()


  describe 'fileopsDelete', ->
    it 'deletes a folder', (done) ->
      @client.fileopsDelete @folderName, undefined, (metadata, error) =>
        expect(error).not.to.be.ok
        metadata = JSON.parse(metadata)
        expect(metadata.path).to.equal @folderName
        done()
