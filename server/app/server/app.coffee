# Server-side Code

exports.actions =

  init: (cb) ->
    cb "SocketStream version #{SS.version} is up and running. This message was sent over websockets, so everything is working OK."

  # Quick Chat Demo
  sendMessage: (message, cb) ->
    if message.length > 0
      # broadcast to everyone
      SS.publish.broadcast 'newMessage', {
        command: message,
        output: 'sample output'
      }
      cb true                                         # Confirm it was sent to the originating client
    else
      cb false
