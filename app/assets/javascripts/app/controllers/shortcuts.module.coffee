$       = jQuery
helpers = require('app/helpers')
Overlay = require('app/controllers/overlay')

class Shortcuts extends Overlay
  className: 'shortcuts'
  helpers: helpers

  constructor: ->
    super
    @render()

  render: =>
    @html(@view('shortcuts')(this))

module.exports = Shortcuts