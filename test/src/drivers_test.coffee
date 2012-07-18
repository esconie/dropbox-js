describe 'DropboxPopupDriver', ->
  describe 'url', ->
    beforeEach ->
      @stub = sinon.stub Dropbox.Drivers.Popup, 'currentLocation'
      @stub.returns 'http://test:123/a/path/file.htmx'

    afterEach ->
      @stub.restore()

    it 'reflects the current page when there are no options', ->
      driver = new Dropbox.Drivers.Popup
      expect(driver.url()).to.equal 'http://test:123/a/path/file.htmx'

    it 'replaces the current file correctly', ->
      driver = new Dropbox.Drivers.Popup receiverFile: 'another.file'
      expect(driver.url()).to.equal 'http://test:123/a/path/another.file#'

    it 'replaces the entire URL correctly', ->
      driver = new Dropbox.Drivers.Popup
        receiverUrl: 'https://something.com/filez'
      expect(driver.url()).to.equal 'https://something.com/filez'
