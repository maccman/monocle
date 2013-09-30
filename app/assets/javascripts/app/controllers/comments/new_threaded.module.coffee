$           = jQuery
Controller  = require('controller')
Comment     = require('app/models/comment')
State       = require('app/state')
helpers     = require('app/helpers')

withUser    = State.withActiveUser

class CommentsNewThreaded extends Controller
  className: 'comments-new-threaded action'

  constructor: (options = {}) ->
    super
    @parent = options.parent or throw new Error('parent required')
    @post   = @parent.get('post') or throw new Error('post required')

    @on 'submit', 'form', @submit
    @on 'keydown', 'form textarea', @checkSubmit
    @on 'focus', 'form textarea', @focus

    @render()

  render: =>
    @html(@view('comments/new_threaded')(this))
    @$form    = @$('form')
    @$comment = @$('textarea')

  valid: =>
    !!@$comment.val()

  # Private

  focus: (e) =>
    unless State.ensureActiveUser()
      e.preventDefault()
      @$comment.blur()

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
        parent: @parent
        formatted_body: mdown
        user_handle: user.get('handle')
        avatar_url: user.get('avatar_url')
        created_at: new Date
      )
      comment.save()
      @parent.addChild(comment)
      @post.increment('comments_count')
      @trigger('created.action', comment)

  checkSubmit: (e) =>
    if e.which is 13 and e.metaKey # Enter
      e.preventDefault()
      @$form.submit()

module.exports = CommentsNewThreaded