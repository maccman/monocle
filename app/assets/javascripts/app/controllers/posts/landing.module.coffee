$           = jQuery
Controller  = require('controller')
State       = require('app/state')

class Landing extends Controller
  className: 'posts-landing'

  constructor: ->
    super
    @render()

  render: =>
    @html(@view('posts/landing')(this))

module.exports = Landing