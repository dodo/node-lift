# node lift

dual side templating.

this library tries to simplify templating by lifting parts of a template to
the client. these parts will be processed, when the client got all data.
it's basicly hiding all client request (like ajax, websockets, etc) for you.

the [example server](https://github.com/dodo/node-lift/blob/master/src/example/server.coffee)
should explain everything.
