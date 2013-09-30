$           = jQuery
Controller  = require('controller')
Comment     = require('app/models/comment')
State       = require('app/state')
helpers     = require('app/helpers')

withUser    = State.withActiveUser

class CommentsNew extends Controller
  className: 'comments-new'

  constructor: (options = {}) ->
    super
    @post = options.post or throw new Error('post required')

    @on 'click', @cancel
    @on 'submit', 'form', @submit
    @on 'keydown', 'form textarea', @checkSubmit
    @on 'focus', 'form textarea', @focused

    $('body').on('click', @checkCollapse)

    @render()

  render: =>
    @html(@view('comments/new')(this))
    @$form    = @$('form')
    @$comment = @$('textarea')

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

    withUser (user) =>
      comment = new Comment(
        body: body
        post: @post
        voted: true
        formatted_body: mdown
        user_handle: user.get('handle')
        avatar_url: user.get('avatar_url')
        created_at: new Date
      )
      comment.save()
      @post.comments.add(comment)
      @post.increment('comments_count')
      @$comment.val('')

  checkSubmit: (e) =>
    if e.which is 13 and e.metaKey # Enter
      e.preventDefault()
      @$form.submit()

  checkCollapse: (e) =>
    @collapse() unless @valid()

  focused: (e) =>
    if State.ensureActiveUser()
      @expand()
    else
      e.preventDefault()
      $(e.currentTarget).blur()

  expand: =>
    @$form.addClass('expanded')

  collapse: =>
    @$form.removeClass('expanded')

  cancel: (e) =>
    e.stopPropagation()

module.exports = CommentsNew