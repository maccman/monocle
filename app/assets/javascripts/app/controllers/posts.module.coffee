$           = jQuery
Controller  = require('controller')
helpers     = require('app/helpers')
State       = require('app/state')
User        = require('app/models/user')
Comments    = require('app/controllers/comments')
UserProfile = require('app/controllers/users/profile')
Details     = require('app/controllers/posts/details')
Landing     = require('app/controllers/posts/landing')
withUser    = State.withActiveUser

class Posts extends Controller
  className: 'posts-show'

  constructor: ->
    super

    @$el.activeArea()
    @on 'click', 'a[data-user-id]', @clickUser

    State.observeKey 'post', =>
      @render(State.get('post'))

  render: (@post) =>
    @$el.empty()

    if @post
      @append(@details  = new Details(post: @post))
      @append(@comments = new Comments(post: @post))
    else
      @append(@landing = new Landing)

  # Private

  clickUser: (e) =>
    e.preventDefault()

    userID = $(e.currentTarget).data('user-id')
    return unless userID

    user   = User.find(userID)
    UserProfile.open(user)

module.exports = Posts