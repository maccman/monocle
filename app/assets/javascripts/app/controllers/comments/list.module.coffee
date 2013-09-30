$           = jQuery
Controller  = require('controller')
Comment     = require('app/models/comment')
State       = require('app/state')
CommentItem = require('app/controllers/comments/item')
withUser    = State.withActiveUser

class CommentsList extends Controller
  className: 'comments-list'

  constructor: (options = {}) ->
    super
    @post = options.post or throw new Error('post required')
    @post.comments.on('observe', @render)
    @render()

  render: =>
    @html(@view('comments')(this))
    @$comments = @$('section.comments-list')

    @post.resolve =>
      @renderComments(@post.comments.all())

  # Private

  renderComments: (@comments) =>
    @$comments.empty()

    for comment in @comments
      item = new CommentItem(comment: comment)
      @$comments.append(item.$el)

  release: =>
    super
    @post?.comments?.off('observe', @render)

module.exports = CommentsList