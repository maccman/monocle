$           = jQuery
Controller  = require('controller')
Comment     = require('app/models/comment')
State       = require('app/state')

CommentsNew  = require('app/controllers/comments/new')
CommentsList = require('app/controllers/comments/list')

withUser    = State.withActiveUser

class Comments extends Controller
  tag: 'article'
  className: 'comments'

  constructor: (options = {}) ->
    super
    @post = options.post or throw new Error('post required')

    @commentsNew  = new CommentsNew(post: @post)
    @commentsList = new CommentsList(post: @post)

    @render()

  render: =>
    @$el.empty()
    @append(@commentsNew)
    @append(@commentsList)

module.exports = Comments