# Client-side Code

# Bind to socket events
SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
SS.socket.on 'reconnect', ->   $('#message').text('SocketStream server is up :-)')

cmView = { products: {all: ['aba','baba','caba','dada','daba'], selected: []}}

generateList = (list) ->
	console.log 'generateList: ' + list
	query = $('#products .query')[0].value
	console.log( query )
	regexp = new RegExp(query)
	html_source = "<select multiple size=30>"
	html_selected = ""
	html_rest = ""
	for product in cmView[list].all
		snippet = "<option id='" + product + "'>" + product + "</option>"
		if product in cmView[list].selected
			html_selected += snippet
		else if query.length is 0 or regexp.test(product)
			html_rest += snippet
	html_source += html_selected + html_rest + "</select>"
	$('#products .content').html(html_source)

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->

  # Make a call to the server to retrieve a message
  SS.server.app.init (response) ->
    $('#message').text(response)

  SS.events.on 'products', (products) ->
    cmView.products.all = products
  	#generateList('products')

  # Listen for new messages and append them to the screen
  SS.events.on 'newMessage', (message) ->
    command = "<p class='command'>#{message.command}</p>"
    output = "<pre class='stdout'>#{message.stdout}</p>" if message.stdout.length > 0
    error = "<pre class='stderr'>#{message.stderr}</p>" if message.stderr.length > 0
    elem = $(command + (output ? "") + (error ? ""))
    elem.hide().prependTo('#activitylog').fadeIn()

  $('#products').show()
  $('#builds').show()
  $('#attempts').show()
  $('#products .query').keyup () ->
    generateList('products')
  	
  $('#activity').show().submit ->
    message = $('#myMessage').val()
    if message.length > 0
      SS.server.app.sendMessage message, (success) ->
        if success then $('#myMessage').val('') else alert('Unable to send message')
    else
      alert('Oops! You must type a message first')

  ### END QUICK CHAT DEMO ####
