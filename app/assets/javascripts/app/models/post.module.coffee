$                   = jQuery
Model               = require('model')
Collection          = require('collection')
PaginatedCollection = require('collection.paginated')
helpers             = require('app/helpers')
SearchCollection    = require('app/models/search').Collection
Comment             = -> require('app/models/comment')

class Post extends Model
  @key 'title', String
  @key 'url', String
  @key 'user_id', String
  @key 'user_handle', String
  @url '/v1/posts'

  @popular: new PaginatedCollection(
    model: this,
    all: (model, options = {}) ->
      $.post(model.uri('popular'), options.data)
    comparator: (a, b) ->
      b.get('score') - a.get('score')
  )

  @newest: new PaginatedCollection(
    model: this,
    all: (model, options = {}) ->
      $.post(model.uri('newest'), options.data)
    comparator: (a, b) ->
      b.get('created_at') - a.get('created_at')
  )

  @search: new SearchCollection(model: this)

  @findBySlug: (slug) ->
    filter  = (r) -> r.get('slug') is slug
    request = => $.getJSON(@uri('slug', slug))
    record  = @findBy(filter, request)
    record.set(slug: slug)
    record

  @suggestTitle: (url) ->
    $.getJSON(@uri('suggest_title'), url: url)

  @refresh: =>
    # Keep trying to refresh until we're
    # successful, as there may be no network
    request = @popular.refresh()
    request.error =>
      setTimeout(@refresh, 4000)
    request.success =>
      @newest.refresh()

  init: ->
    super
    @comments = new (Comment().Collection)(this)

  created_at: (value) ->
    @attributes.created_at = new Date(value) if value
    @attributes.created_at

  ago: (suffix) ->
    created = @get('created_at')
    created and helpers.fromNow(created, suffix)

  truncatedSummary: (length, truncation) ->
    helpers.truncate(@get('summary'), length, truncation)

  navigate: ->
    @set(visited: true)
    window.location = @get('url')

  open: ->
    @set(visited: true)
    window.open(@get('url'))

  vote: (user) ->
    unless user?.get('admin')
      return if @get('voted')

    @set
      votes: (@get('votes') or 0) + 1,
      voted: true

    @trigger 'vote'

    $.ajax
      type:  'POST'
      url:   @uri('vote')
      queue: true
      warn:  true

  icon: ->
    if url = @get('preview_url')
      return helpers.crop(@get('preview_url'), 98, 98)

    if url = @get('link_icon_url')
      return url

module.exports = Post