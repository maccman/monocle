$           = jQuery
Controller  = require('controller')
State       = require('app/state')
helpers     = require('app/helpers')
User        = require('app/models/user')
UserProfile = -> require('app/controllers/users/profile')

class PostItem extends Controller
  helpers: helpers
  className: 'item'

  constructor: (options = {}) ->
    super

    @index = options.index
    @post  = options.post
    @post.observe(@render)

    @on('click', @click)
    @on('click', '.vote', @clickVote)
    @on('click', '.domain', @clickDomain)
    @on('click', 'a[data-user-id]', @clickUser)

    @render()

  render: =>
    @active = @post is State.get('post')
    @html @view('posts/item')(this)
    @$el.toggleClass('active', @active)
    @$el.attr('data-id', @post.get('id'))
    @$el.attr('data-cid', @post.cid)

  # Private

  click: (e) =>
    e.preventDefault()
    @post.open() if e.metaKey
    State.set(post: @post)

  clickVote: (e) =>
    e.preventDefault()

    State.withActiveUser (user) =>
      @post.vote(user)

  clickDomain: (e) =>
    e.preventDefault()

    if e.metaKey
      @post.open()
    else
      @post.navigate()

  clickUser: (e) =>
    e.preventDefault()

    userID = $(e.currentTarget).data('user-id')
    return unless userID

    user   = User.find(userID)
    UserProfile().open(user)

  release: =>
    super
    @post?.unobserve(@render)

module.exports = PostItem