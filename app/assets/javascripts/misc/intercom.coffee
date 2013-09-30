State  = require('app/state')
APP_ID = '1cbb08a44141da674a561a0b6ef920f6f765c64f'

setUser = (user) ->
  return unless user
  return unless State.isProduction()

  attrs = $.extend({},
    user.asJSON(all: true),
    app_id:  APP_ID,
    user_id: user.get('id')
  )

  # Convert dates to integers
  for key, value of attrs when typeof value?.getTime is 'function'
    attrs[key] = value.getTime() / 1000

  Intercom?('boot', attrs)

setup = ->
  State.bind 'user', setUser

$(window).on 'load', ->
  $.getScript('https://static.intercomcdn.com/intercom.v1.js', setup)