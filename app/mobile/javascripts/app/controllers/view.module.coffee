Controller = require('controller')
State      = require('app/state')

class View extends Controller
  constructor: ->
    super
    @on('touchstart', '> .scroll', @hideAddressBar)
    @on('tap', '> header', @tapHeader)
    @on('tap', '.header-back-button', @back)

  # Protected

  hideAddressBar: =>
    @trigger('hide.addressbar.app')

  showAddressBar: =>
    @trigger('show.addressbar.app')

  tapHeader: (e) =>
    # Return unless a direct tap
    return if e.target isnt e.currentTarget

    # If content is scrolled, scroll it to top
    if @$('> .scroll > section').scrollTop() == 0
      @showAddressBar()
    else
      @scrollToTop()

  scrollToTop: =>
    @$('> .scroll > section').scrollTop(0)

  back: =>
    State.toPreviousView()

module.exports = View