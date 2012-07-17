{spawn, exec} = require 'child_process'
log = console.log

task 'build', ->
  build()

task 'test', ->
  build ->
    run 'mocha --colors --require test/js/helper.js test/js/*test.js'
    run 'ender build tests/js/'
    run 'open test/browser_test.html'
    
task 'docs', ->
  run 'docco src/*.coffee'
  
build = (callback) ->
  # Compile without --join for decent error messages.
  run 'coffee --output tmp --compile src/*.coffee', ->
    run 'coffee --output lib --compile --join dropbox.js src/*.coffee', ->
      # Minify the javascript, for browser distribution.
      run 'uglifyjs --no-copyright -o lib/dropbox.min.js lib/dropbox.js', ->
        # Compile with --bare so the imports in helper are available to tests.
        run 'coffee --bare --output test/js --compile test/src/*.coffee',
             callback

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

