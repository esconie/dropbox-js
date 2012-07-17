describe 'DropboxXhr', ->
  describe '#request', ->
    it 'processes errors correctly', (done) ->
      Dropbox.Xhr.request('POST',
        'https://api.dropbox.com/1/oauth/request_token',
        {},
        'OAuth ',
        (data, error) ->
          expect(data).to.equal null
          expect(error).to.be.a 'string'
          expect(error).to.match /^Dropbox API error/
          done()
        )

    it 'processes data correctly', (done) ->
      key = testKeys.key
      secret = testKeys.secret
      timestamp = Math.floor(Date.now() / 1000).toString()
      params =
          oauth_consumer_key: testKeys.key
          oauth_nonce: '_' + timestamp
          oauth_signature: testKeys.secret + '&'
          oauth_signature_method: 'PLAINTEXT'
          oauth_timestamp: timestamp
          oauth_version: '1.0'

      Dropbox.Xhr.request('POST',
        'https://api.dropbox.com/1/oauth/request_token',
        params,
        null,
        (data, error) ->
          expect(error).to.equal undefined
          expect(data).to.have.property 'oauth_token'
          expect(data).to.have.property 'oauth_token_secret'
          done()
        )

    it 'sends Authorize headers correctly', (done) ->
      # This test only works in node.js due to CORS issues on Dropbox.
      unless module? and module?.exports? and require?
        return done()

      key = testKeys.key
      secret = testKeys.secret
      timestamp = Math.floor(Date.now() / 1000).toString()
      oauth_header = "OAuth oauth_consumer_key=\"#{key}\",oauth_nonce=\"_#{timestamp}\",oauth_signature=\"#{secret}%26\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{timestamp}\",oauth_version=\"1.0\""

      Dropbox.Xhr.request('POST',
        'https://api.dropbox.com/1/oauth/request_token',
        {},
        oauth_header,
        (data, error) ->
          expect(error).to.equal undefined
          expect(data).to.have.property 'oauth_token'
          expect(data).to.have.property 'oauth_token_secret'
          done()
        )

  describe '#urlEncode', ->
    it 'iterates properly', ->
      expect(Dropbox.Xhr.urlEncode({foo: 'bar', baz: 5})).to.
        equal 'baz=5&foo=bar' 
    it 'percent-encodes properly', ->
      expect(Dropbox.Xhr.urlEncode({'a +x()': "*b'"})).to.
        equal 'a%20%2Bx%28%29=%2Ab%27' 

  describe '#urlDecode', ->
    it 'iterates properly', ->
      decoded = Dropbox.Xhr.urlDecode('baz=5&foo=bar')
      expect(decoded['baz']).to.equal '5' 
      expect(decoded['foo']).to.equal 'bar' 
    it 'percent-decodes properly', ->
      decoded = Dropbox.Xhr.urlDecode('a%20%2Bx%28%29=%2Ab%27')
      expect(decoded['a +x()']).to.equal "*b'"

