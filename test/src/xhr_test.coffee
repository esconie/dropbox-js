describe 'DropboxXhr', ->
  describe '#request', ->
    it 'processes errors correctly', (done) ->
      Dropbox.Xhr.request('POST',
        'https://api.dropbox.com/1/oauth/request_token',
        {},
        'OAuth ',
        (data, error) ->
          assert.strictEqual data, null
          assert.ok error
          error.should.match /^Dropbox API error/
          done()
        )

    it 'processes data correctly', (done) ->
      key = test_keys.key
      secret = test_keys.secret
      timestamp = Math.floor(Date.now() / 1000).toString()
      oauth_header = "OAuth oauth_consumer_key=\"#{key}\",oauth_nonce=\"_#{timestamp}\",oauth_signature=\"#{secret}%26\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{timestamp}\",oauth_version=\"1.0\""

      Dropbox.Xhr.request('POST',
        'https://api.dropbox.com/1/oauth/request_token',
        {},
        oauth_header,
        (data, error) ->
          assert.strictEqual error, undefined
          assert.ok data
          assert.ok data.oauth_token
          assert.ok data.oauth_token_secret
          done()
        )


  describe '#urlEncode', ->
    it 'iterates properly', ->
      Dropbox.Xhr.urlEncode({foo: 'bar', baz: 5}).should.
        equal 'baz=5&foo=bar' 
    it 'percent-encodes properly', ->
      Dropbox.Xhr.urlEncode({'a +x()': "*b'"}).should.
        equal 'a%20%2Bx%28%29=%2Ab%27' 

  describe '#urlDecode', ->
    it 'iterates properly', ->
      decoded = Dropbox.Xhr.urlDecode('baz=5&foo=bar')
      decoded['baz'].should.equal '5' 
      decoded['foo'].should.equal 'bar' 
    it 'percent-decodes properly', ->
      decoded = Dropbox.Xhr.urlDecode('a%20%2Bx%28%29=%2Ab%27')
      decoded['a +x()'].should.equal "*b'"

