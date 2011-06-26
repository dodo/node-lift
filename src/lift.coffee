

injection_point = (id, injection) ->
    """<script>window.lift.define('#{id}',#{injection.toString()})</script>"""


lift_code = ->
    context = {}
    lift = window.lift =
        call: (id, args...) ->
            context[id]?.apply(0, args)
        get: (id, args...) ->
            new Function "(#{context[id].toString()})(#{args})"
        define: (id, callback) ->
            context[id] = callback
        DEBUG: () -> console.log context


class LiftState
    constructor: (@context) ->
        @lift.code = @code
        @lift.run = @run
        return @lift

    lift: (name, fun) =>
        injection_point name, fun

    code: () =>
        ";lift=(#{lift_code.toString()})();"

    run: (name, args...) =>
        @context[name].apply(this, args)

# exports

module.exports = LiftState
