# Server-side Code
sys = require 'sys'
exec = require('child_process').exec
redis_lib = require('redis')
redis = redis_lib.createClient()

products_observer = redis_lib.createClient()
products_observer.subscribe 'products'
products_observer.on 'message', (channel, msg) ->
  if channel == 'products' then redis.smembers 'products', (err, ids) ->
    SS.publish.broadcast 'products', ids

setInterval(
	() ->
		exec 'cm dbquery -t prod -k Product', (error, stdout, stderr ) ->
			txt = stdout.split "Product) "
			txt = txt[1...txt.length]
			results = for name in txt
				name.replace(/^\s+|\s+$/g,"")
			redis.sadd 'products', results, () -> 
				
			redis.publish 'products', 'on'
	, 10000)


exports.actions =

  init: (cb) ->
    cb "SocketStream version #{SS.version} is up and running. This message was sent over websockets, so everything is working OK."

  # Quick Chat Demo
  sendMessage: (message, cb) ->
    if message.length > 0
      # exec a unix command
      exec message, (error, stdout, stderr ) ->
         # broadcast to everyone
         SS.publish.broadcast 'newMessage', {
           command: message,
           error: error,
           stdout: stdout,
           stderr: stderr
         }
         cb true                                         # Confirm it was sent to the originating client
    else
      cb false

