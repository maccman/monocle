Events = require('events')

class Stream
  @::[k] = v for k,v of Events

  @open: -> @get()

  @get: ->
    @stream or= new this

  logPrefix: '[stream]'

  constructor: (@url = @url) ->
    @source = new EventSource(@url)
    @source.addEventListener('open',  @open, false)
    @source.addEventListener('error', @error, false)
    @source.addEventListener('message', @message, false)
    @source.addEventListener('setup', @setup, false)

  open: =>
    @log 'open'

  error: (e) =>
    @log 'error', e

  message: (e) =>
    msg = JSON.parse(e.data)

    if msg.options?.except is @id
      return @log('ignored', msg.type)
    else
      @log('message', msg.type, msg.data)

    @trigger('message', msg)
    @trigger(msg.type, msg.data)

  setup: (e) =>
    @id = e.data
    @log('setup', @id)
    @trigger('setup', @id)

  log: (args...) =>
    console?.log?(@logPrefix, args...)

module.exports = Stream