$           = jQuery
Controller  = require('controller')
helpers     = require('app/helpers')
State       = require('app/state')
UserProfile = require('app/controllers/users/profile')
UserInvite  = require('app/controllers/users/invite')
Feedback    = require('app/controllers/feedback')

class UserMenu extends Controller
  tag: 'ul'
  helpers: helpers
  className: 'user-menu'

  constructor: (@user) ->
    super()
    @on('click', 'a[data-name=profile]', @clickProfile)
    @on('click', 'a[data-name=invite]', @clickInvite)
    @on('click', 'a[data-name=feedback]', @clickFeedback)
    @on('click', @cancel)
    @user.observe(@render)
    @render()

  render: =>
    @html(@view('sidebar/user_menu')(this))

  toggle: =>
    if @opened then @close() else @open()

  open: =>
    # We don't want to trigger inside the current click event
    setTimeout => $('body').on('click', @close)
    @$el.gfx('raisedIn')
    @opened = true

  close: =>
    $('body').off('click', @close)
    @$el.gfx('raisedOut')
    @opened = false

  # Private

  cancel: (e) =>
    e.stopPropagation()

  clickProfile: (e) =>
    e.preventDefault()
    @close()
    UserProfile.open(@user)

  clickInvite: (e) =>
    e.preventDefault()
    @close()
    UserInvite.open()

  clickFeedback: (e) =>
    e.preventDefault()
    @close()
    Feedback.open()

  release: =>
    super
    @user?.unobserve(@render)

module.exports = UserMenu