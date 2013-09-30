$ = jQuery

queues  = {}
running = false

queue = (name) ->
  name = 'default' if name is true
  queues[name] or= []

next = (name) ->
  list = queue(name)

  unless list.length
    running = false
    return

  [options, deferred] = list.shift()

  $.ajax(options)
    .always(-> next(name))
    .done(-> deferred.resolve(arguments...))
    .fail(-> deferred.reject(arguments...))

push = (name, options) ->
  list = queue(name)
  deferred = $.Deferred()

  list.push([options, deferred])
  next(name) unless running
  running = true
  deferred.promise()

remove = (name, options) ->
  list = queue(name)

  for [value, _], i in list when value is options
    list.splice(i, 1)
    break

$.ajaxTransport '+*', (options) ->
  if options.queue
    queuedOptions = $.extend({}, options)
    queuedOptions.queue = false
    queuedOptions.processData = false

    send: (headers, complete) ->
      push(options.queue, queuedOptions)
        .done (data, textStatus, jqXHR) ->
          complete(jqXHR.status,
                   jqXHR.statusText,
                   text: jqXHR.responseText,
                   jqXHR.getAllResponseHeaders())

        .fail (jqXHR, textStatus, errorThrown) ->
          complete(jqXHR.status,
                   jqXHR.statusText,
                   text: jqXHR.responseText,
                   jqXHR.getAllResponseHeaders())

    abort: ->
      remove(options.queue, queuedOptions)
