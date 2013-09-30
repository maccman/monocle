$          = jQuery
Controller = require('app/controllers/view')
helpers    = require('app/helpers')
State      = require('app/state')
Post       = require('app/models/post')

class Comments extends Controller
  helpers: helpers
  className: 'comments view'

  constructor: ->
    super
    @on('click', 'header a[href]', @open)
    State.change 'post', @setPost

  render: =>
    @html(@view('comments')(this))
    @$thread = @$('section.thread')

    @post.comments.all().promise.done (comments) =>
      @$thread.html(@view('comments/items')(comments: comments))

  # Private

  setPost: (post) =>
    @post?.unobserve(@render)
    @post = post
    @post.observe(@render)
    @post.promise.done(@render)

  open: (e) =>
    e.preventDefault()
    @post.open()

module.exports = Comments