# Client-side Code

# Bind to socket events
SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
SS.socket.on 'reconnect', ->   $('#message').text('SocketStream server is up :-)')

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->

  # Make a call to the server to retrieve a message
  SS.server.app.init (response) ->
    $('#message').text(response)

  # Listen for new messages and append them to the screen
  SS.events.on 'newMessage', (message) ->
    command = "<p class='command'>#{message.command}</p>"
    output = "<pre class='stdout'>#{message.stdout}</p>" if message.stdout.length > 0
    error = "<pre class='stderr'>#{message.stderr}</p>" if message.stderr.length > 0
    elem = $(command + (output ? "") + (error ? ""))
    elem.hide().prependTo('#activitylog').fadeIn()
  
  $('#activity').show().submit ->
    message = $('#myMessage').val()
    if message.length > 0
      SS.server.app.sendMessage message, (success) ->
        if success then $('#myMessage').val('') else alert('Unable to send message')
    else
      alert('Oops! You must type a message first')

  ### END QUICK CHAT DEMO ####
