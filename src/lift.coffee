
# helper

injection_point = (id, locals, injection) ->
    """<script>window.lift.define('#{id}',#{locals},#{injection})</script>"""


lift_client_code = ->
    slice = Array.prototype.slice # to avoid coffeescript optimization
    context = {}
    lift = window.lift =
        call: (id) -> # all other arguments passed to the context function
            args = slice.call(arguments, 1)
            func = context[id]
            func.apply(this, func.args.concat(args))
        define: (id, args, func) -> # private function; called at injection points
            func.args = args
            context[id] = func
        DEBUG: () -> console.log "LIFT-CONTEXT", context

# lib

class LiftState
    constructor: () ->
        @context = {}
        my = this

        # defined here to preserve LiftState's this and function caller's this
        @lift = (id, args..., func) ->
            return injection_point(id, JSON.stringify(args), func) unless my.context[id]?
            func.apply(this, args.concat(my.context[id])) # call direct


        # this little trick makes the LiftState instance callable
        @lift.direct = @direct
        @lift.code = @code = LiftState.code
        @lift.self = this # dont hide LiftState instance
        return @lift

    direct: (name, args...) =>
        @context[name] = args


# code needed on client side
LiftState.code = () ->
    ";lift=(#{lift_client_code})();"

module.exports = LiftState
