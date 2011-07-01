{LiftState, CoffeeKupRenderer, JQueryJSONHandler} = require('../lift')
connect = require('connect')
coffeekup = require('coffeekup')

# client part

template = ->
    doctype 5
    html ->
        head ->
            meta charset:'utf-8'
            title @title or "lifted!"
            style '''
                body {font-family: sans-serif}
                header, nav, section, footer {display: block}
            '''
            script src:'http://code.jquery.com/jquery-1.6.1.min.js' # lift is using jquery to :/
            script src:'http://coffeekup.org/coffeekup.js' # because the client side part is using this as well
            script {type:'text/javascript'}, @lift.code() # all needed boilerplade code. it also defines 'lift' in the global context
            coffeescript ->
                $().ready ->
                    lift.DEBUG()
                    lift.load('test') # requesting data for part 'test'
        body ->
            text 'lifting data to the next request layer:'
            @lift 'test', (data) -> # defining the client side part
                text data.value
                div style:'color:red', ->
                    text 'awesome!'


# server part

server = connect.createServer connect.logger(), (req, res) ->
    state = new LiftState renderer:CoffeeKupRenderer, handler:JQueryJSONHandler,
        # defining the server side of the lifted parts
        test: () -> {value:'finely done.'}

    return if state.handle(req, res) # process all ajax request
    # normal page …
    body = coffeekup.render template, context:{lift:state}, format:on
    # normal http server foo
    res.setHeader('Content-Length', body.length)
    res.end(body)


server.listen(3000)
console.log "server listening on port 3000 …"

