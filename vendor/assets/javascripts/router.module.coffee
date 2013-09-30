namedParam   = /:([\w\d]+)/g
splatParam   = /\*([\w\d]+)/g
escapeRegExp = /[-[\]{}()+?.,\\^$|#\s]/g

class Route
  constructor: (@path, @callback) ->
    @names = []

    if typeof path is 'string'
      namedParam.lastIndex = 0
      while (match = namedParam.exec(path)) != null
        @names.push(match[1])

      splatParam.lastIndex = 0
      while (match = splatParam.exec(path)) != null
        @names.push(match[1])

      path = path.replace(escapeRegExp, '\\$&')
                 .replace(namedParam, '([^\/]*)')
                 .replace(splatParam, '(.*?)')

      @route = new RegExp('^' + path + '$')
    else
      @route = path

  match: (path) ->
    match = @route.exec(path)
    return false unless match

    params = {match: match}

    if @names.length
      for param, i in match.slice(1)
        params[@names[i]] = param

    @callback.call(null, params) isnt false

class Router
  constructor: ->
    @routes = []
    $(window).on('popstate', @change)

  add: (path, callback) ->
    if (typeof path is 'object' and path not instanceof RegExp)
      return @add(key, value) for key, value of path

    @routes.push(new Route(path, callback))

  navigate: (@path) =>
    return if @locationPath() is @path

    history?.pushState?(
      {},
      document.title,
      @path
    )

  locationPath: =>
    path = window.location.pathname
    if path.substr(0,1) isnt '/'
      path = '/' + path
    path

  change: =>
    path  = @locationPath()
    return if path is @path
    @path = path
    @matchRoute(@path)

  matchRoute: (path, options) =>
    for route in @routes
      if route.match(path, options)
        return route

module.exports = Router