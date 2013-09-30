$         = jQuery
Authorize = require('app/controllers/users/authorize')
Manifesto = require('app/controllers/users/manifesto')

class InviteAuthorize extends Authorize
  className: 'users-invite-authorize'

  constructor: (@invite) ->
    super(-> Manifesto.open())

  render: =>
    @html(@view('users/invite_authorize')(this))

module.exports = InviteAuthorize