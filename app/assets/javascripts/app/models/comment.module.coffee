$          = jQuery
Model      = require('model')
Collection = require('collection')
moment     = require('moment')
Post       = -> require('app/models/post')

class Comment extends Model
  @key 'body', String
  @key 'parent_id', String
  @key 'post_id', String
  @key 'user_handle', String
  @key 'user_id', String
  @url '/v1/comments'

  created_at: (value) =>
    @attributes.created_at = new Date(value) if value
    @attributes.created_at

  ago: (suffix) =>
    created = @get('created_at')
    created and moment(created).fromNow(suffix)

  children: (values = []) =>
    for value in values
      @addChild(value, true)
    @attributes.children or= []

  addChild: (value, silent = false) =>
    children = @attributes.children or= []
    child    = new @constructor(value)

    child.add()
    child.observe(@childrenChange)
    child.set(parent: this)

    children.unshift(child)
    children.sort((a, b) -> b.get('score') - a.get('score'))

    @childrenChange() unless silent

  childrenChange: =>
    @trigger 'observe:children', [], this
    @trigger 'observe', [], this

  depth: ->
    if count = @attributes.depth
      return count

    count   = 0
    comment = this

    while comment = comment.get('parent')
      count += 1

    @attributes.depth = count

  vote: (user) =>
    unless user?.get('admin')
      return if @get('voted')

    @set
      votes: (@get('votes') or 0) + 1,
      voted: true

    $.ajax
      type: 'POST'
      url:   @uri('vote')
      queue: true
      warn:  true

  post: (value) =>
    @set(post_id: value.getID()) if value?
    @get('post_id') and Post().find(@get('post_id'))

  parent: (value) =>
    if value?
      @attributes.parent = value
      @set(parent_id: value and value.get('id'))
    @attributes.parent

  canReply: =>
    @get('depth') < 3

  canEdit: (user) =>
    return true if user?.get('admin')
    @get('user_id') is user?.get('id')

class CommentCollection extends Collection
  constructor: (@post) ->
    super(model: Comment)

  asyncAllRequest: =>
    $.getJSON(@post.uri('comments'), threaded: true)

  comparator: (a, b) ->
    aScore = a.get('score')
    bScore = b.get('score')
    aDate  = a.get('created_at')
    bDate  = b.get('created_at')

    # We want to make sure that new comments
    # without a score are the top of the thread
    if aScore and bScore
      super(bScore, aScore)
    else
      super(bDate, aDate)

module.exports = Comment
module.exports.Collection = CommentCollection