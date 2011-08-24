
# helper

injection_point = (id, locals, injection) ->
    """<script>window.lift.define('#{id}',#{locals},#{injection})</script>"""


lift_client_code = ->
    slice = Array.prototype.slice # to avoid coffeescript optimization
    context = {}
    lift = window.lift =
        context:context
        call: (id) -> # all other arguments passed to the context function
            args = slice.call(arguments, 1)
            func = context[id]
            func.apply(this, func.args.concat(args))
        get: (id) -> # all other arguments passed to the context function
            args = slice.call(arguments, 1)
            func = context[id]
            do (id, args, func) ->
                return -> # all arguments passed to the context function
                    argz = slice.call(arguments)
                    func.apply(this, func.args.concat(args).concat(argz))
        define: (id, args, func) -> # private function; called at injection points
            func.args = args
            context[id] = func
        DEBUG: () -> console.log "LIFT-CONTEXT", context

# lib

class LiftState
    constructor: () ->
        @context = direct:{}, get:{}
        my = this

        # defined here to preserve LiftState's this and function caller's this
        @lift = (id, args..., func) ->
            if my.context.direct[id]? # call direct
                func.apply(this, args.concat(my.context.direct[id]))
            else if my.context.get[id]? # return lift function
                my.context.get[id].apply(this, [func].concat(args))
            else # insert script tag
                args = for arg in args
                    if typeof arg is 'function'
                        "(#{arg})"
                    else
                        JSON.stringify(arg)
                return injection_point(id, "[#{args}]", func)


        # this little trick makes the LiftState instance callable
        @lift.get = @get
        @lift.direct = @direct
        @lift.code = @code = LiftState.code
        @lift.self = this # dont hide LiftState instance
        return @lift

    direct: (name, args...) =>
        @context.direct[name] = args

    get: (name, callback) =>
        @context.get[name] = callback


# code needed on client side
LiftState.code = () ->
    ";lift=(#{lift_client_code})();"

module.exports = LiftState
