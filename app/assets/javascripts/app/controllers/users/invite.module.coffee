$       = jQuery
helpers = require('app/helpers')
Overlay = require('app/controllers/overlay')
User    = require('app/models/user')
State   = require('app/state')

class Invite extends Overlay
  className: 'users-invite'
  helpers: helpers

  constructor: ->
    super
    @user = State.get('user')
    @full = State.get('hasAdminUser')
    @on 'submit', @submit
    @render()

  render: =>
    @html(@view('users/invite')(this))
    @$email   = @$('input[name=email]')
    @$twitter = @$('input[name=twitter]')
    @$github  = @$('input[name=github]')

  # Private

  submit: (e) =>
    e.preventDefault()
    return unless @valid()
    @user.invite(
      email:   @$email.val()
      twitter: @$twitter.val()
      github:  @$github.val()
    )
    @close()

  valid: =>
    for input in @$('input[required]')
      return false unless input.value
    true

module.exports = Invite