$       = jQuery
State   = require('app/state')
Overlay = require('app/controllers/overlay')

class Manifesto extends Overlay
  className: 'manifesto'

  constructor: (@callback) ->
    super()
    @user = State.get('user')
    @render()
    @closed(@callback) if @callback
    @closed(@seen)

  render: =>
    @html(@view('users/manifesto')(this))

  # Protected

  seen: =>
    return unless @user
    return if @user.get('manifesto')
    @user.set(manifesto: true)
    @user.save()

module.exports = Manifesto