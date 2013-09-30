$           = jQuery
Controller  = require('controller')
Comment     = require('app/models/comment')
State       = require('app/state')
helpers     = require('app/helpers')

withUser    = State.withActiveUser

class CommentsEdit extends Controller
  className: 'comments-edit action'

  constructor: (options = {}) ->
    super
    @comment = options.comment or throw new Error('comment required')

    @on 'submit', 'form', @submit
    @on 'keydown', 'form textarea', @checkSubmit

    @render()

  render: =>
    @html(@view('comments/edit')(this))
    @$form    = @$('form')
    @$comment = @$('textarea').select()

  valid: =>
    !!@$comment.val()

  # Private

  submit: (e) =>
    e.preventDefault()
    return unless @valid()

    # Generate some temporary markdown before the
    # server responds with the real stuff
    body   = $.trim(@$comment.val())
    bparts = helpers.escape(body).split("\n")
    mdown  = ("<p>#{b}</p>" for b in bparts when b).join('')

    @comment.set(
      body: body,
      formatted_body: mdown
    )
    @comment.save()
    @trigger('updated.action', @comment)

  checkSubmit: (e) =>
    if e.which is 13 and e.metaKey # Enter
      e.preventDefault()
      @$form.submit()

module.exports = CommentsEdit