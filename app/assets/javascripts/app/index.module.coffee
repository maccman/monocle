$               = jQuery
Controller      = require('controller')
Session         = require('session')
InviteAuthorize = require('app/controllers/users/invite_authorize')
Sidebar         = require('app/controllers/sidebar')
Posts           = require('app/controllers/posts')
Post            = require('app/models/post')
User            = require('app/models/user')
Stream          = require('app/models/stream')
Invite          = require('app/models/invite')
State           = require('app/state')
Router          = require('app/router')
KeyBinding      = require('app/key_binding')

class App extends Controller
  className: 'app'
  version: '0.1.5'

  constructor: (options = {}) ->
    super
    State.set(environment: options.environment)
    State.set(user: options.user and new User(options.user))

    Session.setCSRFToken(options.csrfToken)
    Post.popular.add(options.posts)

    @append(@sidebar = new Sidebar)
    @append(@posts = new Posts)

    # Make sidebar the active area
    @sidebar.$el.click()

    # Trigger a route
    (@router = new Router).change()

    # Add key bindings
    @keyBinding = new KeyBinding

    $(window).on('load',   => Stream.open())
    $(window).on('online', => Post.refresh())
    $(document).on('wake', => Post.refresh())

    if invite = options.invite
      InviteAuthorize.open(new Invite(invite))

module.exports = App