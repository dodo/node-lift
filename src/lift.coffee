{parse} = require('url')

# helper

injection_point = (id, locals, injection) ->
    """<script>window.lift.define('#{id}',#{locals},#{injection})</script>"""


lift_code = ->
    slice = Array.prototype.slice
    context = {}
    closure = (id) ->
        resume = context[id]
        args = (JSON.stringify(arg) for arg in slice.call(arguments, 1))
        new Function "with(#{resume.locals}){(#{resume})(#{args.join(',')})}"
    lift = window.lift =
        call: (id) -> # all other arguments passed to the context function
            args = slice.call(arguments, 1)
            context[id]?.apply(0, args)
        load: (id) -> # all other arguments passed to client part of handler
            args = slice.call(arguments)
            args = args.concat [(data) -> lift.render(id, closure(id, data))]
            lift.request.apply(this, args)
        define: (id, locals, resume_state) ->
            resume_state.locals = JSON.stringify(locals)
            context[id] = resume_state
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

    client: (name, url, next) ->
        $.ajax(url).success(next) # FIXME to lazy to replace this

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

        # {server:function(state,req,res){…}, client:function(args...,next){…}}
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
    lift: (name, locals, fun) =>
        [fun, locals] = [locals, {}] unless fun
        locals ?= {}
        locals = JSON.stringify(locals) # WARNING just json, no functions allowed! :(
        @renderer.server(name, injection_point(name, locals, fun))

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

module.exports = {LiftState, State:LiftState,
    # renderer
    PlainRenderer,
    CoffeeKupRenderer,
    # handler
    JQueryHTMLHandler,
    JQueryJSONHandler,
}
