Model         = require('model')

class State extends Model
  withUser: (callback) =>

  withActiveUser: (callback) =>

  toView: (view, dir) =>
    @previousView = @view
    @view = view
    @trigger('view', @view, dir)

  toPreviousView: =>
    @view = @previousView
    @previousView = null
    @trigger('view', @view, 'ltr')

module.exports = new State