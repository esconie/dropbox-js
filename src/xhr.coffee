if window?
  XMLHttpRequest = window.XMLHttpRequest  
  # TODO: XDomain for CORS on IE <= 9
else
  # Node.js needs an adapter for the XHR API.
  XMLHttpRequest = require('xmlhttprequest').XMLHttpRequest

# Dispatches low-level XmlHttpRequests
class DropboxXhr
  # Send off an AJAX request.
  #
  # @param {String} method the HTTP method used to make the request ('GET',
  #     'POST', etc)
  # @param {String} url the HTTP URL (e.g. "http://www.example.com/photos")
  #     that receives the request
  # @param {Object} params an associative array (hash) containing the HTTP
  #     request parameters
  # @param {String} authHeader the value of the Authorization header
  # @param {function(?Object, ?String)}callback called with the AJAX result;
  #     successful requests set the first parameter to an object containing the
  #     parsed result, and unsuccessful requests set the second parameter to
  #     an error string
  @request: (method, url, params, authHeader, callback, request_body) ->
    if method is 'GET' or method is 'PUT'
      url = [url, '?', DropboxXhr.urlEncode(params)].join ''
    xhr = new XMLHttpRequest()
    xhr.open method, url, true
    if authHeader
      xhr.setRequestHeader 'Authorization', authHeader
    xhr.onreadystatechange = -> DropboxXhr.onReadyStateChange(xhr, callback)
    if method is 'POST'
      xhr.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded'
      body = DropboxXhr.urlEncode(params)
      xhr.send body
    else if method is 'PUT'
      xhr.send request_body
    else
      xhr.send()
    null

  # Encodes an associative array (hash) into a x-www-form-urlencoded String.
  #
  # For consistency, the keys are encoded using 
  #
  # @param {Object} object the JavaScript object whose keys will be encoded
  # @return {String} the object's keys and values, encoded using
  #     x-www-form-urlencoded
  @urlEncode: (object) ->
    chunks = []
    for key, value of object
      chunks.push @urlEncodeValue(key) + '=' + @urlEncodeValue(value)
    chunks.sort().join '&'

  # Encodes an object into a x-www-form-urlencoded key or value.
  # 
  # @param {Object} object the object to be encoded; the encoding calls
  #     toString() on the object to obtain its string representation
  # @return {String} encoded string, suitable for use as a key or value in an
  #     x-www-form-urlencoded string
  @urlEncodeValue: (object) ->
    encodeURIComponent(object.toString()).replace(/\!/g, '%21').
      replace(/'/g, '%27').replace(/\(/g, '%28').replace(/\)/g, '%29').
      replace(/\*/g, '%2A')

  # Decodes an x-www-form-urlencoded String into an associative array (hash).
  #
  # @param {String} string the x-www-form-urlencoded String to be decoded
  # @return {Object} an associative array whose keys and values are all strings
  @urlDecode: (string) ->
    result = {}
    for token in string.split '&' 
      kvp = token.split '='
      result[decodeURIComponent(kvp[0])] = decodeURIComponent kvp[1] 
    result

  # Handles the XHR readystate event.
  @onReadyStateChange: (xhr, callback) ->
    if xhr.readyState is 4  # XMLHttpRequest.DONE is 4
      response = xhr.responseText
      if xhr.status < 200 or xhr.status >= 300
        callback null, "Dropbox API error #{xhr.status}. #{response}"
        return
      switch xhr.getResponseHeader('Content-Type')
         when 'application/x-www-form-urlencoded'
           callback DropboxXhr.urlDecode(response)
         when 'application/json'
           callback JSON.parse(response)
         else
            callback response
    true
