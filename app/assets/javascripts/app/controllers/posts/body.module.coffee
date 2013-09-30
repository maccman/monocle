$       = jQuery
helpers = require('app/helpers')
Overlay = require('app/controllers/overlay')
Post    = require('app/models/post')

class PostBody extends Overlay
  className: 'posts-body'
  helpers: helpers

  @open: (post) ->
    return unless post.get('summary')
    super(post)

  constructor: (@post) ->
    super()
    $(window).on('message', @message)
    $(window).on('keydown', @keydown)
    @render()

  render: =>
    @html(@view('posts/body')(this))

  center: ->
    # Noop

  message: (e) =>
    e = e.originalEvent
    return unless e.data?.briskClose
    @close()

  release: =>
    super
    $(window).off('message', @message)
    $(window).off('keydown', @keydown)

  keydown: (e) =>
    return if 'value' of e.target

    if e.which is 82 # 'r'
      e.stopImmediatePropagation()
      e.preventDefault()
      @close()

module.exports = PostBody