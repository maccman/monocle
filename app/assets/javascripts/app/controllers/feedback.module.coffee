$       = jQuery
helpers = require('app/helpers')
Overlay = require('app/controllers/overlay')
State   = require('app/state')

class Feedback extends Overlay
  className: 'feedback'
  helpers: helpers

  constructor: ->
    super
    @user = State.get('user')
    @on 'submit', @submit
    @render()

  render: =>
    @html(@view('feedback')(this))
    @$email = @$('input[type=email]')
    @$text  = @$('textarea')

  submit: (e) =>
    e.preventDefault()
    return unless @$text.val()

    $.post(
      '/v1/feedback',
      text:  @$text.val(),
      email: @$email.val()
    )

    @close()

module.exports = Feedback