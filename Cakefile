path = require 'path'
{ run, compileScript } = require 'muffin'


task 'build', 'compile coffeescript → javascript', (options) ->
    run
        options:options
        files:[
            "./src/**/*.coffee"
        ]
        map:
            'src/example/(.+).coffee': (m) ->
                compileScript m[0], path.join("example" ,"#{m[1]}.js"), options
            'src/(.+).coffee': (m) ->
                compileScript m[0], path.join("lib" ,"#{m[1]}.js"), options
