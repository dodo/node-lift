LiftState = require('../lift')
connect = require('connect')
coffeekup = require('coffeekup')

# client part

support = '''
  var __slice = Array.prototype.slice;
  var __hasProp = Object.prototype.hasOwnProperty;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  var __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype;
    return child;
  };
  var __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
'''

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
            script src:'http://code.jquery.com/jquery-1.6.1.min.js'
            script src:'http://coffeekup.org/coffeekup.js'
            script {type:'text/javascript'}, @support
            script {type:'text/javascript'}, @lift.code()
            coffeescript ->
                get = (id) ->
                    $.ajax(url:'/?id='+id, type:'POST').success (data) ->
                        $('#lifted_'+id).html window.CoffeeKup.render window.lift.get(id, data)

                $().ready ->
                    lift.DEBUG()
                    get 'test'
        body ->
            text 'lifting data to the next request layer:'
            div id:'lifted_test', ->
                @lift 'test', (data) ->
                    text data.value
                    div style:'color:red', ->
                        text 'awesome!'


# server part


server = connect.createServer connect.logger(), connect.query(), (req, res) ->
    state = new LiftState
        test: () -> {value:'finely done.'}

    if req.method is 'POST'
        console.log req.query
        body = JSON.stringify state.run req.query.id
    else
        body = coffeekup.render template, context:{lift:state, support}, format:on

    res.setHeader('Content-Length', body.length)
    res.end(body)


server.listen(3000)
console.log "server listening on port 3000 …"



