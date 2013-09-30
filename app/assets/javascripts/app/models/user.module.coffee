$          = jQuery
Model      = require('model')
Collection = require('collection')
Post       = -> require('app/models/post')

class User extends Model
  @url '/v1/users'
  @key 'manifesto', Boolean

  init: ->
    super

    @posts = new Collection(
      model: Post(),
      name: 'users/posts',
      all: => $.getJSON(@uri('posts'))
      comparator: (a, b) ->
        b.get('created_at') - a.get('created_at')
    )

    @votedPosts = new Collection(
      model: Post(),
      all: => $.getJSON(@uri('voted_posts'))
      comparator: (a, b) ->
        b.get('created_at') - a.get('created_at')
    )

  created_at: (value) ->
    @attributes.created_at = new Date(value) if value
    @attributes.created_at

  invite: (values) ->
    count = @get('invites_count', 0)
    @set('invites_count', --count)
    $.post(@constructor.uri('invite'), values)

  register: (email) ->
    @set(email: email)

    @set @request = $.post(
      @constructor.uri('register'),
      email: @get('email')
    )

  save: =>
    @add()
    @request = @set $.ajax
      type: 'POST'
      url:  @constructor.uri('current')
      data: @toJSON()
      warn: true
    this

module.exports = User