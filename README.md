# node lift

dual side templating.

this library tries to simplify templating by lifting parts of a template to
the client. these parts will be processed, when the client got all data.
it's basicly hiding all client request (like ajax, websockets, etc) for you.

## usage

first you need to include everything you need:
```javascript
var lift = require('lift'),
    LiftState = lift.State, JQueryJSONHandler = lift.JQueryJSONHandler;
```

the next thing is to define every part on server side:
```javascript
state = new LiftState({handler:JQueryJSONHandler},{
    // defining the server side of the lifted parts
    test: function () {
        return {value:'finely done.'};
    },
});
if (state.handle(req, res)) return; // process all ajax requests
```

with this new state you can now create the client side of the parts:
```javascript
state('test', function (data) {
    // this will be done after an ajax request from the client.
    return data.value.toUpperCase();
});
```

the [example server](https://github.com/dodo/node-lift/blob/master/src/example/server.coffee)
should explain everything else. it also contains a little more complex flavor of
the above exmaple with [coffeekup](http://coffeekup.org/).
