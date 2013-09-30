$        = jQuery
Overlay  = require('app/controllers/overlay')
Post     = require('app/models/post')
State    = require('app/state')
withUser = State.withActiveUser

class NewPost extends Overlay
  className: 'posts-new'

  open: ->
    withUser =>
      super

  constructor: ->
    super
    @on 'submit', @submit
    @on 'change', 'input[name=url]', @suggestTitle
    @render()

  render: =>
    @scheduled = State.hasAdminUser()
    @html(@view('posts/new')(this))
    @$form  = @$('form')
    @$url   = @$('input[name=url]')
    @$title = @$('input[name=title]')

  # Private

  valid: ->
    for input in @$('input[required]')
      return false unless input.value
    true

  submit: (e) =>
    e.preventDefault()

    return unless @valid()

    post = new Post
    post.fromForm(@$form)
    post.save()

    # Toggle inputs
    @$(':input').blur().attr('disabled', true)
    post.request.complete =>
      @$(':input').attr('disabled', false)

    # Only display post if successfully created
    post.request.success =>
      Post.newest.add(post)
      Post.newest.resort()
      State.set(post: post)
      State.set(sidebar: 'newest')

      @close()

  suggestTitle: =>
    val = @$url.val()
    return unless val

    Post.suggestTitle(val).success (suggest) =>
      return if @$title.val()
      @$title.val(suggest.title).select()


module.exports = NewPost