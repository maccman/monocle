Collection = require('collection')

class PaginatedCollection extends Collection
  next: =>
    @sort()

    ids  = (rec.get('id') for rec in @records)
    data = ignore: ids

    @all(remote: true, request: {data: data})

module.exports = PaginatedCollection