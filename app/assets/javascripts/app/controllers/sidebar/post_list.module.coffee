Controller = require('controller')
State      = require('app/state')
PostItem   = require('app/controllers/posts/item')

class PostList extends Controller
  className: 'list posts-list'

  constructor: (options = {}) ->
    super

    @hasIndex   = options.hasIndex
    @collection = options.collection

    @collection.on('add', @addOne)
    @collection.on('reset', @reset)
    @collection.on('resort', @render)

    @addPagination() if @collection.next

    # Set active state whenever someone
    # goes to a specific post
    State.change('post', @setPost)

    @render()

  render: =>
    @$el.empty()
    @addAll()

  # Private

  reset: =>
    @$el.empty()

  addPagination: =>
    @$el.infinite =>
      @collection.next().request

  setActive: =>
    @$('.item').removeClass('active')

    if @post
      $active = @$(".item[data-id=#{@post.get('id')}]")
      $active.addClass('active')

    @$('.item.active:visible:first').scrollIntoViewIfNeeded()

  setPost: (@post) =>
    @setActive()

  addOne: (post) =>
    index = @hasIndex and @collection.records.indexOf(post)
    @append new PostItem(
      post:  post,
      index: index
    )

  addAll: =>
    @collection.each(@addOne)

module.exports = PostList