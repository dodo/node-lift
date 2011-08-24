# node lift

dual side templating, made easy.

this library simplifies templating by lifting parts of a template to
the client. these parts will be processed, when the client got all data.

## installation

    npm install lift

## server side api

### LiftState

```javascript
LiftState = require('lift')
lift = new LiftState()
```

it actually returns a function, so `lift` is callable.
the LiftState instance can be accessed via `lift.self`.

### lift

```javascript
lift(id, static_args..., function ([static_args...], [dynamic_args...], [data]) {…})
```
* `static_args` arguments defined on server side
* `dynamic_args` arguments given on client side
* `data` given on client side

this defines a function that can run on server or client (decision can be made per request by calling `lift.direct` or `lift.get` before).
it is best used in the views to define lazy template parts.

### lift.direct

```javascript
lift.direct(id, args..., data)
```

sets the arguments of given `id`-part. when `id`-part gets defined it will be called direct.
useful to render parts on server side.

### lift.get

```javascript
lift.get(id, function (lifted_function) {…});
```

define a function that will be invoked with the requested `id`-part.
useful to render parts on server side.

### lift.code

```javascript
client_side_code = lift.code() // or LiftState.code()
script_tag = '<script type="text/javascript">' + client_side_code + '</script>'
```

returns client side code. only needed once per request.

## client side api

### window.lift

```javascript
lift || window.lift // same
```

this is the client side of the library. it returns from `LiftState.code()`.

### window.lift.call

```javascript
lift.call(id, [dynamic_args...], [data])
```
* `dynamic_args` arguments defined on client side
* `data` defined on client side

this invokes the `id`-part at the client defined on server side.

### window.lift.get

```javascript
fun = lift.get(id, [dynamic_args...])
func([data])
```
* `dynamic_args` arguments defined on client side
* `data` defined on client side

similar to `window.lift.call` but just returns a function containing all server and client side arguments and the `id`-part.

### window.lift.DEBUG

```javascript
lift.DEBUG()
```

it prints the context to the console. the context contains every function and its arguments defined by calling `lift` on server side.

## NOTE

this library does not specify on which channels (socket.io, ajax, comet, jsonp, etc …) the data is passing to the client.

## example

the [example server](https://github.com/dodo/node-lift/blob/master/src/example/server.coffee) should explain everything else.

influenced by [lifts lazy load idea](http://demo.liftweb.net/lazy).

