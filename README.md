# node lift

dual side templating, made easy.

this library tries to simplify templating by lifting parts of a template to
the client. these parts will be processed, when the client got all data.

## installation

    npm install lift

## api

### LiftState

```javascript
LiftState = require('lift')
lift = new LiftState()
```

it actually returns a function, so `lift` is callable.
the LiftState instance can be accessed via `lift.self`.

### lift

```javascript
lift(id, static_args..., function (static_args..., dynamic_args..., data) {…})
```
this is the main part of the library.
it defines a function that can run on server or client (decision can be made per request by calling `lift.direct` before).
it is best used in the views to define lazy template parts.

### lift.direct

```javascript
lift.direct(id, args..., data)
```

sets the arguments of given `id`-part. when `id`-part gets defined it will be called direct.
useful to render parts on server side.

### lift.code

```javascript
client_side_code = lift.code() // or LiftState.code()
script_tag = '<script type="text/javascript">' + client_side_code + '</script>'
```

returns client side code. only needed once per request.

## example

the [example server](https://github.com/dodo/node-lift/blob/master/src/example/server.coffee) should explain everything else.

influenced by [lifts lazy load idea](http://demo.liftweb.net/lazy).

