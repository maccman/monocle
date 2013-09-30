$          = jQuery
Collection = require('collection')

class SearchCollection extends Collection
  comparator: (a, b) ->
    b.get('created_at') - a.get('created_at')

  all: =>
    @records

  query: (value) =>
    request = $.get(@model.uri('search'), q: value)
    request.done (result) =>
      @reset()
      @add(result)
    request

exports.Collection = SearchCollection