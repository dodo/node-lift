{parse} = require('url')

# helper

injection_point = (id, injection) ->
    """<script>window.lift.define('#{id}',#{injection})</script>"""


lift_code = ->
    slice = Array.prototype.slice
    context = {}
    closure = (id) ->
        args = (JSON.stringify(arg) for arg in slice.call(arguments, 1))
        new Function "(#{context[id]})(#{args.join(',')})"
    lift = window.lift =
        call: (id) ->
            args = slice.call(arguments, 1)
            context[id]?.apply(0, args)
        load: (id) ->
            lift.request id, (data) ->
                lift.render(id, closure(id, data))
        define: (id, callback) ->
            context[id] = callback
        DEBUG: () -> console.log "LIFT-CONTEXT", context

# Renderers

PlainRenderer = # default
    server: (id, data) ->
        '<div id="lifted-'+id+'">' + data + '</div>'

    client: (id, data) ->
        document.getElementById('lifted-'+id).innerHTML = data

CoffeeKupRenderer =
    server: (id, data) ->
        '<div id="lifted-'+id+'">' + data + '</div>'

    client: (id, data) ->
        document.getElementById('lifted-'+id).innerHTML =
            window.CoffeeKup.render(data)

# Handler

JQueryHTMLHandler = # default
    server: (state, req, res) ->
        {query} = parse(req.url, true)
        return false unless state.has(query.lift)
        body = state.run(query.lift, req, res)
        res.setHeader('Content-Length', body.length)
        res.setHeader('Content-Type', "text/html")
        res.write(body)
        res.end()
        return true

    client: (name, next) ->
        $.ajax(url:'?lift='+name).success(next) # FIXME to lazy to replace this

JQueryJSONHandler =
    server: (state, req, res) ->
        {query} = parse(req.url, true)
        return false unless state.has(query.lift)
        body = JSON.stringify(state.run(query.lift, req, res))
        res.setHeader('Content-Length', body.length)
        res.setHeader('Content-Type', "application/json")
        res.write(body)
        res.end()
        return true

    client: (name, next) ->
        $.ajax(url:'?lift='+name).success(next) # FIXME to lazy to replace this

# lib

class LiftState
    constructor: (opts, context) ->
        [context, opts] = [opts, {}] unless context?

        # contains all server parts
        @context = context or {}

        # {server:function(state,req,res){…}, client:function(name,next){…}}
        # its job is to transport data
        @handler  = opts.handler  or JQueryHTMLHandler

        # {server:function(id,data){…}, client:function(id,data){…}}
        # its job is to fit data into document
        @renderer = opts.renderer or PlainRenderer

        # this little trick makes the LiftState callable
        @lift.handle = @handle
        @lift.code = @code
        @lift.run = @run
        @lift.has = @has
        return @lift

    # defines a client part by name
    lift: (name, fun) =>
        @renderer.server(name, injection_point(name, fun))

    # handles a client request by given handler
    handle: (req, res) =>
        @handler.server(this, req, res)

    # code needed on client side
    code: () =>
        ";lift=(#{lift_code})();" +
        "lift.render=#{@renderer.client};" +
        "lift.request=#{@handler.client};"

    # invoke server part by name
    run: (name, args...) =>
        @context[name].apply(this, args)

    # check if part exists on server side
    has: (name) =>
        @context[name]?


# exports

module.exports = {LiftState,
    # renderer
    PlainRenderer,
    CoffeeKupRenderer,
    # handler
    JQueryHTMLHandler,
    JQueryJSONHandler,
}
