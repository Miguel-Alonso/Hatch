# Client-side Code
Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1

# Bind to socket events
SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
SS.socket.on 'reconnect', ->   $('#message').text('SocketStream server is up :-)')

cmView = { products: {all: [], selected: []}, builds: {all: [], selected: []}}

selectedUpdated = (list) ->
    child_list = ''
    if list == 'products'
       child_list = 'builds'
    else
       return
    tosend = []
    for item in cmView[list].selected
        tosend.push item.replace(/'/g,"")
    SS.server.app.getUpdate list, tosend, (ids) ->
        cmView[child_list].all = ids
        generateList(child_list)

generateList = (list) ->
	query = $('#' + list + ' .query')[0].value
	regexp = new RegExp(query)
	selected = $("<span></span>")
	rest = $("<span></span>")
	for item in cmView[list].all
		item = item.replace(/'/g,"")
		object = $("<p>" + item + "</p>")
		if item in cmView[list].selected
			object.addClass 'selected'
			object.appendTo selected
			object.bind 'click', {item: item}, (event) ->
			    item = event.data.item
			    cmView[list].selected.remove item if item in cmView[list].selected
			    generateList(list)
			    selectedUpdated(list)
		else if query.length is 0 or regexp.test(item)
			object.appendTo rest
			object.bind 'click', {item: item}, (event) ->
			    item = event.data.item
			    cmView[list].selected.push item if item not in cmView[list].selected
			    generateList(list)
			    selectedUpdated(list)
	$('#' + list + ' .content').empty()
	selected.appendTo $('#' + list + ' .content')
	rest.appendTo $('#' + list + ' .content')


# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->

  # Make a call to the server to retrieve a message
  SS.server.app.init (response) ->
    cmView.products.all = response
    generateList('products')

  SS.events.on 'products', (products) ->
    cmView.products.all = products
    generateList('products')

  SS.events.on 'builds', (builds) ->
    cmView.builds.all = builds
    generateList('builds')

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
  $('#products .query').keyup(() ->
    generateList('products')
  )

  $('#builds .query').keyup(() ->
    generateList('builds')
  )
