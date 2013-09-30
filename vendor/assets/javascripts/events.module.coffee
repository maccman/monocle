Events =
  on: (event, callback) ->
    if typeof event isnt 'string'
      throw new Error('event required')

    if typeof callback isnt 'function'
      throw new Error('callback required')

    events = event.split(' ')
    calls  = @hasOwnProperty('events') and @events or= {}

    for name in events
      calls[name] or= []
      calls[name].push(callback)
    this

  isOn: (event, callback) ->
    list = @hasOwnProperty('events') and @events?[event]
    list and callback in list

  one: (event, callback) ->
    if typeof callback isnt 'function'
      throw new Error('callback required')

    callee = ->
      @off(event, callee)
      callback.apply(this, arguments)
    @on(event, callee)

  trigger: (args...) ->
    event = args.shift()
    list  = @hasOwnProperty('events') and @events?[event]
    iargs = args.concat([this])

    for callback in list or []
      if callback.apply(this, iargs) is false
        break

    unless event is 'all'
      @trigger('all', event, args)

    true

  off: (event, callback) ->
    unless event
      @events = {}
      return this

    list = @events?[event]
    return this unless list

    unless callback
      delete @events[event]
      return this

    for cb, i in list when cb is callback
      list = list.slice()
      list.splice(i, 1)
      @events[event] = list
      break
    this

module.exports = Events