describe 'DropboxClient', ->
  beforeEach ->
    @node_js = module? and module?.exports? and require?
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

    it 'removes multiple leading /s from absolute paths', ->
      expect(@client.normalizePath('///aa/b/ccc/dd')).to.equal 'aa/b/ccc/dd'

  describe 'isCopyRef', ->
    it 'recognizes the copyRef in the API example', ->
      expect(@client.isCopyRef('z1X6ATl6aWtzOGq0c3g5Ng')).to.equal true

    it 'rejects paths starting with /', ->
      expect(@client.isCopyRef('/z1X6ATl6aWtzOGq0c3g5Ng')).to.equal false

    it 'rejects paths containing /', ->
      expect(@client.isCopyRef('z1X6ATl6aWtzOGq0c3g5N/g')).to.equal false

    it 'rejects paths containing .', ->
      expect(@client.isCopyRef('z1X6ATl6aWtzOGq0c3g5N.g')).to.equal false

  describe 'authenticate', ->
    it 'completes the flow', (done) ->
      @timeout 15 * 1000  # Time-consuming because the user must click.
      @client.reset()
      @client.authDriver authDriverUrl, authDriver
      @client.authenticate (uid, error) ->
        expect(error).to.not.be.ok
        expect(uid).to.be.a 'string'
        done()

  describe 'getUserInfo', ->
    it 'returns reasonable information', (done) ->
      @client.getUserInfo (userInfo, error) ->
        expect(error).to.not.be.ok
        expect(userInfo).to.have.property 'uid'
        expect(userInfo.uid.toString()).to.equal testKeys.uid
        expect(userInfo).to.have.property 'referral_link'
        expect(userInfo).to.have.property 'display_name'
        done()

  describe 'mkdir', ->
    it 'creates a folder', (done) ->
      @folderName = '/jsapi-tests' + Math.random().toString(36)
      @client.mkdir @folderName, (metadata, error) =>
        expect(error).not.to.be.ok
        expect(metadata).to.have.property 'path'
        expect(metadata.path).to.equal @folderName
        done()

  describe 'writeFile', ->
    it 'writes a file to Dropbox', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      contents = "This is the api secret\n"
      @client.writeFile filePath, contents, (metadata, error) ->
        expect(error).to.not.be.ok
        expect(metadata).to.have.property 'path'
        expect(metadata.path).to.equal filePath
        done() 

  describe 'readFile', ->
    it 'reads a file from Dropbox', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      contents = "This is the api secret\n"
      @client.readFile filePath, (data, error) ->
        expect(error).to.not.be.ok
        expect(data).to.equal contents
        done()

  describe 'readFile', ->
    it 'reads binary data correctly', (done) ->
      filename = "js-api-test.gif"
      @client.readFile filename, {'fetchBinary': true}, (data, error) =>
        expect(error).to.not.be.ok
        if document?
          img = document?.createElement('img')
          img?.src = window.webkitURL?.createObjectURL(data)
          document?.body.appendChild(img)
        else
          require('fs').writeFileSync('/Users/aakanksha/Pictures/pic.gif', data, 'binary')
        @client.writeFile filename, data, (metadata, error) ->
          expect(error).to.not.be.ok
          done()

  describe 'writeFile', ->
    it 'writes image to the server correctly', (done) ->
      filename = "/Users/aakanksha/Pictures/Bonsai.gif"
      if not require?('fs')?
        done()
      data = require('fs').readFileSync(filename)
      filePath = "/bonsaisss.gif"
      @client.writeFile filePath, data, (metadata, error) ->
        expect(error).to.not.be.ok
        expect(metadata).to.have.property 'path'
        expect(metadata.path).to.equal filePath
        done()

  describe 'stat', ->
    it 'retrieves metadata for a file', (done) ->
      @client.stat 'api-test.txt', (metadata, error) ->
        expect(error).not.to.be.ok
        expect(metadata).to.have.property 'path'
        expect(metadata.path).to.equal '/api-test.txt'
        done()

  describe 'history', ->
    it 'gets a list of revisions', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      @client.history filePath, (versions, error) ->
        expect(error).not.to.be.ok
        expect(versions).to.have.length 1
        done()

  describe 'restore', ->
    it 'restores a file (deletes it first)', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      @client.remove filePath, (metadata, error) ->
        expect(error).not.to.be.ok
        expect(metadata.path).to.equal filePath
        done()

  describe 'history', ->
    it 'gets a list of revisions', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      @client.history filePath, (metadata, error) =>
        expect(error).not.to.be.ok
        rev = metadata[1].rev
        @client.restore filePath, rev, undefined, (metadata, error) ->
          expect(metadata.path).to.equal filePath
          done()

  describe 'search', ->
    it 'searches for files', (done) ->
      folderName = @folderName.substring 1
      @client.search '/', folderName, undefined, undefined, undefined, (metadata, error) ->
        expect(error).not.to.be.ok
        expect(metadata.length).to.equal 1
        done()

  describe 'makeUrl for a short Web URL', ->
    it 'returns a shortened Dropbox URL', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      @client.makeUrl filePath, (urlData, error) ->
        expect(error).not.to.be.ok
        expect(urlData).to.have.property 'url'
        expect(urlData.url).to.contain '//db.tt/'
        done()

  describe 'makeUrl for a Web URL', ->
    it 'returns an URL to a preview page', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      @client.makeUrl filePath, { long: true }, (urlData, error) ->
        expect(error).not.to.be.ok
        expect(urlData).to.have.property 'url'
        
        # The contents server does not return CORS headers.
        return done() unless @nodejs
        Dropbox.Xhr.request 'GET', urlData.url, {}, null, (data, error) ->
          expect(error).not.to.be.ok
          expect(data).to.contain '<!DOCTYPE html>'
          done()

  describe 'makeUrl for a direct download URL', ->
    it 'gets a direct download URL', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      @client.makeUrl filePath, { download: true }, (urlData, error) ->
        expect(error).not.to.be.ok
        expect(urlData).to.have.property 'url'

        # The contents server does not return CORS headers.
        return done() unless @nodejs
        Dropbox.Xhr.request 'GET', urlData.url, {}, null, (data, error) ->
          expect(error).not.to.be.ok
          expect(data).to.equal "This is the api secret\n"
          done()

  describe 'delta', ->
    it 'gets a list of changes', (done) ->
      @client.delta undefined, undefined, (metadata, error) ->
        expect(error).not.to.be.ok
        done()

  describe 'copy', ->
    it 'copies a file', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      @client.copy filePath, "#{filePath}_copy", (metadata, error) ->
        expect(error).not.to.be.ok
        expect(metadata.path).to.equal "#{filePath}_copy"
        done()

  describe 'move', ->
    it 'moves a file', (done) ->
      filePath = "#{@folderName}/api-test.txt"
      @client.move filePath, "#{filePath}_copy2", (metadata, error) ->
        expect(error).not.to.be.ok
        expect(metadata.path).to.equal "#{filePath}_copy2"
        done()


  describe 'remove', ->
    it 'deletes a folder', (done) ->
      @client.remove @folderName, (metadata, error) =>
        expect(error).not.to.be.ok
        expect(metadata.path).to.equal @folderName
        done()
