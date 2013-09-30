$       = jQuery
Events  = require('events')

class Collection
  @::[k] = v for k,v of Events

  constructor: (options = {}) ->
    unless options.model
      throw new Error('Model required')

    @ids               = {}
    @cids              = {}
    @records           = options.records or []
    @model             = options.model
    @comparator        = options.comparator if options.comparator

    @promise           = $.Deferred().resolve(@records)
    @records.observe   = @observe
    @records.unobserve = @unobserve
    @records.promise   = @promise

    if 'all' of options
      @asyncAllRequest = options.all

    if 'find' of options
      @asyncFindRequest = options.find

  find: (id, options = {}) =>
    unless id
      throw new Error('id required')

    if typeof id.getID is 'function'
      id = id.getID()

    record = @syncFind(id)
    record or= @baseSyncFind(id)

    if record and not options.remote
      record
    else
      @asyncFind(id, options)

  findBy: (callback, request) =>
    unless typeof callback is 'function'
      throw new Error('callback function required')

    @syncFindBy(callback) or @asyncFindBy(request)

  refresh: (options = {}) =>
    @reset()
    @fetch(options)

  all: (callback, options = {}) =>
    if typeof callback is 'object'
      options  = callback
      callback = null

    if @shouldPreload() or options.remote
      result = @asyncAll(options)
    else
      result = @records

    @promise.done(callback) if callback

    result

  fetch: (options = {}) =>
    @asyncAll(options).request

  each: (callback) =>
    @all().promise.done (records) =>
      callback(rec) for rec in records

  sort: (callback = @comparator) =>
    @records.sort(callback) if callback
    @trigger('sort')
    this

  resort: (callback) =>
    @sort(callback)
    @trigger('resort')
    this

  exists: (record) =>
    if typeof record is 'object'
      id  = record.getID()
      cid = record.getCID()
    else
      id = cid = record

    id of @ids or cid of @cids

  empty: =>
    @records.length is 0

  add: (records) =>
    return unless records

    # If we're passed a unforfilled promise, then
    # re-add when the promise is finished.
    if typeof records.done is 'function'
      records.done(@add)
      return records

    unless $.isArray(records)
      records = [records]

    # Instantiate the array into model
    # instances if they aren't already
    records = new @model(records)
    changes = []

    for record, i in records
      # If the record already exists, use the same object
      original = @model.collection?.syncFind(record.getID())

      if original
        original.set(record)
        @cids[record.getCID()] or= original
        record = records[i] = original

      continue if @exists(record)

      # Record record, and map IDs for faster lookups
      @records.push(record)
      @cids[record.getCID()] = record
      @ids[record.getID()]   = record if record.getID()

      # Make sure changes are propogated
      record.on('all', @recordEvent)

      # Trigger events
      @trigger('add', record)

      changes.push(
        name: record.getCID(), type: 'new',
        object: this, value: record
      )

    @sort()

    # Unless we're the model's base collection
    # also add the record to that
    @model.add(records) unless @isBase()

    @trigger('observe', changes)
    records

  remove: (records) =>
    unless $.isArray(records)
      records = [records]

    for record in records[..]
      # Remove event listeners
      record.off('all', @recordEvent)

      # Remove IDs references
      delete @cids[record]
      delete @ids[record.getID()] if record.getID()

      # Lastly remove record
      index = @records.indexOf(record)
      @records.splice(index, 1)

  reset: =>
    @remove(@records)

    @ids  = {}
    @cids = {}

    @trigger('reset',)
    @trigger('observe', [])

  observe: (callback) =>
    @on('observe', callback)

  unobserve: (callback) =>
    @off('observe', callback)

  # Protected

  comparator: (a, b) ->
    if a > b
      return 1
    else if a < b
      return -1
    else
      return 0

  recordEvent: (event, args, record) =>
    @trigger("record.#{event}", record, args)

  shouldPreload: =>
    @empty() and !@request

  isBase: =>
    @model.collection is this

  asyncAll: (options = {}) =>
    return unless @asyncAllRequest and @model.uri()

    @request = @asyncAllRequest.call(@model, @model, options.request)
    @records.request = @request
    @records.promise = @promise = $.Deferred()
    @request.done (result) =>
      @add(result)
      @promise.resolve(@records)
    @records

  syncFindBy: (callback) =>
    @records.filter(callback)[0]

  asyncFindBy: (asyncRequest) =>
    return unless asyncRequest and @model.uri()

    record         = new @model
    request        = asyncRequest.call(@model, record)
    record.request = request
    record.promise = $.Deferred()

    request.done (response) =>
      record.set(response)
      record.promise.resolve(record)
      @add(record)

    record

  asyncFind: (id, options = {}) =>
    return unless @asyncFindRequest and @model.uri()

    record         = new @model(id: id)
    request        = @asyncFindRequest.call(@model, record, options.request)
    record.request = request
    record.promise = $.Deferred()

    request.done (response) =>
      record.set(response)
      record.promise.resolve(record)
      @add(record)

    record

  syncFind: (id) =>
    @ids[id] or @cids[id]

  baseSyncFind: (id) =>
    unless @isBase()
      record = @model.collection?.syncFind(id)
      @add(record) if record and not @exists(record)
      record

  asyncAllRequest: (model, options = {}) =>
    defaults =
      url: model.uri()
      dataType: 'json'
      type: 'GET'

    $.ajax($.extend(defaults, options))

  asyncFindRequest: (record, options = {}) =>
    defaults =
      url: record.uri()
      dataType: 'json'
      type: 'GET'

    $.ajax($.extend(defaults, options))

module.exports = Collection