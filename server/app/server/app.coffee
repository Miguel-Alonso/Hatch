# Server-side Code
sys = require 'sys'
exec = require('child_process').exec
redis_lib = require('redis')
redis = redis_lib.createClient()

products_observer = redis_lib.createClient()
products_observer.subscribe 'products'
products_observer.on 'message', (channel, msg) ->
  if channel == 'products' then redis.smembers 'products', (err, ids) ->
    SS.publish.broadcast 'newMessage', {
      command: 'products channel update',
      stderr: 'count: ' + ids.length,
      stdout: ids
    }

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

