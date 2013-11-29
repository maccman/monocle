Model         = require('model')
User          = -> require('app/models/user')
AuthorizeUser = -> require('app/controllers/users/authorize')
Manifesto     = -> require('app/controllers/users/manifesto')

class State extends Model
  withUser: (callback) =>
    if user = @get('user')
      callback.call(this, user)
    else
      console?.warn('Not logged in')
      AuthorizeUser().open (user) =>
        callback.call(this, user)

  withActiveUser: (callback) =>
    @withUser (user) =>
      @withSeenManifesto =>
        callback.call(this, user)

  withSeenManifesto: (callback) =>
    @withUser (user) =>
      if user.get('manifesto') is false
        Manifesto().open =>
          callback.call(this, user)
      else
        callback.call(this, user)

  hasAdminUser: =>
    !!@get('user')?.get('admin')

  ensureActiveUser: =>
    user = @get('user')

    unless user
      AuthorizeUser().open()
      return false

    unless user.get('manifesto')
      Manifesto().open()
      return false

    true

  isProduction: =>
    @get('environment') is 'production'

module.exports = new State