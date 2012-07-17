describe 'Oauth', ->
  beforeEach ->
    @oauth = new Dropbox.Oauth
      key: 'dpf43f3p2l4k3l03',
      secret: 'kd94hf93k423kf44'
    @oauth.setToken 'nnch734d00sl2jdk', 'pfkkdhi9sl3r4s00'

    # The example in OAuth 1.0a Appendix A.
    @request =
      method: 'GET',
      url: 'http://photos.example.net/photos'
      params:
        file: 'vacation.jpg',
        size: 'original'
    @dateStub = sinon.stub Date, 'now'
    @dateStub.returns 1191242096999

  afterEach ->
    @dateStub.restore()

  describe '#boilerplateParams', ->
    it 'issues unique nonces', ->
      nonces = {}
      for i in [1..100]
        nonce = @oauth.boilerplateParams({}).oauth_nonce
        nonces.should.not.have.property nonce
        nonces[nonce] = true

    it 'fills all the arguments', ->
      params = @oauth.boilerplateParams(@request.params)
      properties = ['oauth_consumer_key', 'oauth_nonce',
                    'oauth_signature_method', 'oauth_timestamp',
                    'oauth_version']
      for property in properties
        params.should.have.property property

  describe '#signature', ->
    it 'works for the OAuth 1.0a example', ->
      @nonceStub = sinon.stub @oauth, 'nonce'
      @nonceStub.returns 'kllo9940pd9333jh'

      @oauth.boilerplateParams(@request.params)
      @oauth.signature(@request.method, @request.url, @request.params).
        should.equal 'tR3+Ty81lMeYAr/Fid0kMTYa/WM='

      @nonceStub.restore()

  describe '#authHeader', ->
    it 'matches the OAuth 1.0a example', ->
      @nonceStub = sinon.stub @oauth, 'nonce'
      @nonceStub.returns 'kllo9940pd9333jh'

      golden_header = 'OAuth oauth_consumer_key="dpf43f3p2l4k3l03",oauth_nonce="kllo9940pd9333jh",oauth_signature="tR3%2BTy81lMeYAr%2FFid0kMTYa%2FWM%3D",oauth_signature_method="HMAC-SHA1",oauth_timestamp="1191242096",oauth_token="nnch734d00sl2jdk",oauth_version="1.0"'
      @oauth.authHeader(@request.method, @request.url, @request.params).
          should.equal golden_header

      @nonceStub.restore()

    it "doesn't leave any OAuth-related value in params", ->
      @oauth.authHeader(@request.method, @request.url, @request.params)
      Dropbox.Xhr.urlEncode(@request.params).should.
          equal "file=vacation.jpg&size=original"

