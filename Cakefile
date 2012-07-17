{spawn, exec} = require 'child_process'
fs = require 'fs'
log = console.log
open = require 'open'

task 'build', ->
  build()

task 'test', ->
  vendor ->
    build ->
      run 'mocha --colors --require test/js/helper.js test/js/*test.js'
      run 'open test/browser_test.html'

task 'test2', ->
  vendor ->
    build ->
      open './test/browser_test.html'
    
task 'docs', ->
  run 'docco src/*.coffee'
  
task 'vendor', ->
  vendor()

build = (callback) ->
  # Compile without --join for decent error messages.
  run 'coffee --output tmp --compile src/*.coffee', ->
    run 'coffee --output lib --compile --join dropbox.js src/*.coffee', ->
      # Minify the javascript, for browser distribution.
      run 'uglifyjs --no-copyright -o lib/dropbox.min.js lib/dropbox.js', ->
        run 'coffee --output test/js --compile test/src/*.coffee', ->
          run 'browserify test/js/web_requires.js -o test/js/web_node_mocks.js',
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
    callback()
    return

  run "curl -o #{file} #{url}", callback
