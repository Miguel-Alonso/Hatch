# Server-side Code
sys = require 'sys'
exec = require('child_process').exec
redis_lib = require('redis')

host = "mpp-dev.ie.office.aol.com"
port = 6379

redis = redis_lib.createClient(port, host)

products_observer = redis_lib.createClient(port, host)
products_observer.subscribe 'products'
products_observer.on 'message', (channel, msg) ->
  if channel == 'products' then redis.smembers 'products', (err, ids) ->
    SS.publish.broadcast 'products', ids

setInterval(
	() ->
		exec 'cm dbquery -t prod -s Product', (error, stdout, stderr ) ->
			txt = stdout.split "Product) "
			txt = txt[1...txt.length]
			for name in txt
				redis.sadd 'products', name.replace(/^\s+|\s+$/g,"")
			redis.publish 'products', 'on'
	, 60 * 60 * 1000)


exports.actions =

  init: (cb) ->
    redis.smembers 'products', (err, ids) ->
      cb ids

  getUpdate: (list, args, cb) ->
    if list is 'products'
      response = []
      toread = args.length
      for product in args
        redis.lrange 'builds:' + product, 0, 1000, (err, ids) ->
          response = response.concat ids
          toread -= 1
          if toread == 0
            console.log response
            cb response
    else
      cb []

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

