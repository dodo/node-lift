LiftState = require('../lift')
coffeekup = require('coffeekup') # http://coffeekup.org/
connect = require('connect')
{parse} = require('url')

# client side

template = -> # coffeekup
    doctype 5
    html ->
        head ->
            meta charset:'utf-8'
            title @title or "lifted!"
            style 'body {font-family: sans-serif}'
            script src:'http://code.jquery.com/jquery-1.6.1.min.js'
            script src:'http://coffeekup.org/coffeekup.js' # because the client side part is using this as well
            script {type:'text/javascript'}, @lift.code() # all needed boilerplate code. it also defines 'lift' in the global context; only need once
            coffeescript -> # client code
                $('document').ready ->
                    lift.DEBUG()
                    # requesting data for part 'test'
                    setTimeout ->
                        $.getJSON "?", lift:'test', (data) ->
                            $('#test-content').html lift.call('test', window.CoffeeKup, data)
                    , 2000 # 2sec delay
        body ->
            text 'lifting data to the next request layer:'
            div id:'hit-content',  ->
                @lift 'hit', @remoteAddr, (addr, ck, data) ->
                    ck.render ->
                        text data.value
                        div style:'color:blue', ->
                            text "this was fast."
                        small style:'color:gray', ->
                            text "request by #{addr}"
                    ,locals:{data, addr}
            div id:'test-content', ->
                text "* loading content  …"
                # defining the client side part
                @lift 'test', @remoteAddr, (addr, ck, data) ->
                    ck.render ->
                        text data.value
                        div style:'color:red', ->
                            text "awesome!"
                        small style:'color:gray', ->
                            text "request by #{addr}"
                    ,locals:{data, addr}


# server side

server = connect.createServer connect.logger(), (req, res) ->
    {query, pathname} = parse(req.url, true)
    unless pathname is "/"
        res.statusCode = 404
        return res.end()

    state = new LiftState

    # we want to render the given liftstate aspect on the server
    state.direct('hit',
        {render:((f)->f())}, # ck - just a dummy because we are allready in coffeekup
        {value:"other lift has a 2sec delay"}) # data - normal payload data

    if query.lift # ajax request …
        res.setHeader('Content-Type', "application/json")
        if query.lift is 'hit'
            body = value:"forever alone data"
        else if query.lift is 'test'
            body = value:"laziness is"
        body = JSON.stringify body
    else # normal page …
        res.setHeader('Content-Type', "text/html")
        context =
            lift:state
            remoteAddr:req.socket.remoteAddress
        body = coffeekup.render template, {context, format:on}
    # normal http server foo
    res.setHeader('Content-Length', body.length)
    res.end(body)


server.listen(3000)
console.log "server listening on port 3000 …"

