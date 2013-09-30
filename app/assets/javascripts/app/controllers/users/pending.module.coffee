$       = jQuery
Overlay = require('app/controllers/overlay')
User    = require('app/models/user')
State   = require('app/state')

class Pending extends Overlay
  className: 'users-pending'

  constructor: ->
    super()
    @user = State.get('user')
    @on 'submit', @submit
    @render()

  render: =>
    @html(@view('users/pending')(this))
    @$email  = @$('input[name=email]')

  submit: (e) =>
    e.preventDefault()
    @user.register(@$email.val())
    @$el.addClass('submitted')
    setTimeout(@close, 3000)

module.exports = Pending