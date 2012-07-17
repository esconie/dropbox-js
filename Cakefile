{spawn, exec} = require 'child_process'
fs = require 'fs'
log = console.log

task 'build', ->
  build()

task 'test', ->
  vendor ->
    build ->
      token ->
        run 'mocha --colors --require test/js/helper.js test/js/*test.js'
        run 'open test/browser_test.html'

task 'webtest', ->
  vendor ->
    build ->
      token ->
        webFileServer = require './test/js/web_file_server.js'
        webFileServer.openBrowser()
    
task 'docs', ->
  run 'docco src/*.coffee'
  
task 'vendor', ->
  vendor()

task 'token', ->
  build ->
    token ->
      process.exit 0

build = (callback) ->
  # Compile without --join for decent error messages.
  run 'coffee --output tmp --compile src/*.coffee', ->
    run 'coffee --output lib --compile --join dropbox.js src/*.coffee', ->
      # Minify the javascript, for browser distribution.
      run 'uglifyjs --no-copyright -o lib/dropbox.min.js lib/dropbox.js', ->
        run 'coffee --output test/js --compile test/src/*.coffee',
            callback

vendor = (callback) ->
  # All the files will be dumped here.
  unless fs.existsSync
    fs.mkdirSync 'test/vendor'

  # chai.js ships different builds for browsers vs node.js
  download 'http://chaijs.com/chai.js', 'test/vendor/chai.js', ->
    download 'http://sinonjs.org/releases/sinon.js', 'test/vendor/sinon.js', ->
      download 'http://sinonjs.org/releases/sinon-ie.js',
               'test/vendor/sinon-ie.js', callback

token = (callback) ->
  TokenStash = require './test/js/token_stash.js'
  tokenStash = new TokenStash
  (new TokenStash()).get ->
    callback() if callback?

run = (args...) ->
  for a in args
    switch typeof a
      when 'string' then command = a
      when 'object'
        if a instanceof Array then params = a
        else options = a
      when 'function' then callback = a
  
  command += ' ' + params.join ' ' if params?
  cmd = spawn '/bin/sh', ['-c', command], options
  cmd.stdout.on 'data', (data) -> process.stdout.write data
  cmd.stderr.on 'data', (data) -> process.stderr.write data
  process.on 'SIGHUP', -> cmd.kill()
  cmd.on 'exit', (code) -> callback() if callback? and code is 0

download = (url, file, callback) ->
  if fs.existsSync file
    callback() if callback?
    return

  run "curl -o #{file} #{url}", callback
