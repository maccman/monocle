$           = jQuery
Controller  = require('controller')
State       = require('app/state')
helpers     = require('app/helpers')
EditComment = require('app/controllers/comments/edit')
NewComment  = require('app/controllers/comments/new_threaded')

class CommentItem extends Controller
  helpers: helpers
  className: 'item comment'

  constructor: (options) ->
    super

    @comment = options.comment or throw new Error('comment required')
    @comment.observe(@render)

    @on 'click', '> .meta .vote', @clickVote
    @on 'click', '> .meta .reply', @clickReply
    @on 'click', '> .meta .edit', @clickEdit
    @on 'action', '> .action', @removeStates

    @render()

  render: =>
    @user = State.get('user')

    @$el.removeClass('replying editing')
    @$el.toggleClass('child', !!@comment.get('parent_id'))
    @$el.toggleClass('thread', !@comment.get('parent_id'))
    @$el.attr(cid: @comment.getCID(), id: @comment.getID())

    @html(@view('comments/item')(this))
    @$body = @$('.body')

    for child in @comment.get('children')
      @append new CommentItem(comment: child)

  # Private

  clickVote: (e) =>
    e.preventDefault()

    State.withActiveUser (user) =>
      @comment.vote(user)

  clickReply: (e) =>
    e.preventDefault()

    unless @newComment
      @newComment = new NewComment(parent: @comment)
      @$body.after(@newComment.$el)

    @$el.removeClass('editing')
    @$el.toggleClass('replying')

  clickEdit: (e) =>
    e.preventDefault()

    unless @editComment
      @editComment = new EditComment(comment: @comment)
      @$body.after(@editComment.$el)

    @$el.removeClass('replying')
    @$el.toggleClass('editing')

  removeStates: =>
    @$el.removeClass('replying editing')

  release: =>
    super
    @comment?.unobserve(@render)

module.exports = CommentItem