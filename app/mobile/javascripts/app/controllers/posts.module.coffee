$          = jQuery
Controller = require('app/controllers/view')
helpers    = require('app/helpers')
State      = require('app/state')
Post       = require('app/models/post')

class Posts extends Controller
  helpers: helpers
  className: 'posts view loading'

  constructor: ->
    super

    @collection = Post.popular
    @collection.on 'add', @addOne
    @collection.fetch().done(@done)

    @on 'click', 'a[href]', @cancel
    @on 'tap', 'a[href]', @tap
    @on 'tap', 'a.more', @tapMore
    @on 'tap', 'a.next', @tapNext
    @on 'tap', '.item', @highlight

    @render()

  render: =>
    @html(@view('posts')(this))
    @$posts = @$('.posts-list ul')
    @addAll()

  # Private

  done: =>
    @$el.removeClass('loading')

  addOne: (post) =>
    @$posts.append(@view('posts/item')(post: post))

  addAll: =>
    @collection.each(@addOne)

  cancel: (e) =>
    e.preventDefault()

  tap: (e) =>
    e.preventDefault()

    $item  = $(e.currentTarget).closest('.item')
    postID = $item.data('id')
    post   = Post.find(postID)

    State.set(post: post)
    post.navigate()

  tapMore: (e) =>
    e.preventDefault()

    $item  = $(e.currentTarget).closest('.item')
    postID = $item.data('id')
    post   = Post.find(postID)

    State.set(post: post)
    State.toView('comments')

  tapNext: (e) =>
    Post.popular.next()

  highlight: (e) =>
    $item = $(e.currentTarget)
    $item.tapactive()
    setTimeout ->
      $item.tapblur()
    , 400

module.exports = Posts