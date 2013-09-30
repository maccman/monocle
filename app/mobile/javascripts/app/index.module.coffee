$          = jQuery
Controller = require('controller')
Session    = require('session')
Post       = require('app/models/post')
User       = require('app/models/user')
State      = require('app/state')
Router     = require('app/router')
Posts      = require('app/controllers/posts')
Comments   = require('app/controllers/comments')

class App extends Controller
  className: 'app mobile'

  constructor: (options = {}) ->
    super
    Session.setCSRFToken(options.csrfToken)

    @append(@posts = new Posts)
    @append(@comments = new Comments)

    # Setup current user
    State.set(user: options.user and new User(options.user))
    State.on('view', @setView)

    # Hide address bar on scroll
    @hideAddressBar()
    @on('hide.addressbar.app', @hideAddressBar)
    @on('show.addressbar.app', @showAddressBar)

    # Trigger a route
    (@router = new Router).change()

  hideAddressBar: =>
    $('body').css(height: window.screen.height)
    setTimeout ->
      window.scrollTo(0, 0)
      $('body').css(height: window.innerHeight)
    , 1

  showAddressBar: =>
    $('body').css(height: '100%')

  animation: {
    rtl: ['slide-out-to-left', 'slide-in-from-right'],
    ltr: ['slide-out-to-right', 'slide-in-from-left']
  }

  setView: (viewName = 'posts', dir = 'rtl') =>
    unless view = @[viewName]
      throw new Error("Unknown view '#{viewName}'")

    unless animation = @animation[dir]
      throw new Error("Unknown animation '#{dir}'")

    # Already on this view
    return if view.$el.is(@$current)

    @$previous = @$current
    @$current  = view.$el
    @$current.addClass('active')

    # No previous view, so no transitions
    return unless @$previous

    done = =>
      @$previous.removeClass('active')
      @$previous.removeClass(animation[0]).removeClass('slide')
      @$current.removeClass(animation[1]).removeClass('slide')

    @$previous.one('webkitAnimationEnd', done)
    @$previous.addClass('slide').addClass(animation[0])
    @$current.addClass('slide').addClass(animation[1])

module.exports = App