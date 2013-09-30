$          = jQuery
Controller = require('controller')

class Overlay extends Controller
  tag: 'article'
  timeout: $.support.transition and 400

  @open: (options) ->
    unless @instance?.isOpen()
      @instance = new this(options).open()
    @instance

  constructor: ->
    super
    @on('click', '.close', @close)

    @$el.addClass('panel')
    @$overlay = $('<div />').addClass('overlay')
    @$overlay.click(@checkClose)
    @$el.appendTo(@$overlay)

  isOpen: =>
    @state() is 'opened'

  open: =>
    @$overlay.appendTo('body')
    @$overlay.redraw().addClass('active')
    @center()
    $('body').on('keydown', @checkKey)
    setTimeout(@opened, 600)
    this

  close: =>
    @$overlay.removeClass('active')
    setTimeout(=>
      @$overlay.detach()
      @closed()
      @off()
    , @timeout)
    this

  state: (value) =>
    @istate = value if value?
    @istate

  opened: (callback) =>
    if typeof callback is 'function'
      if @state() is 'opened'
        do callback
      else
        @$el.one('open.overlay', callback)

    else
      @state 'opened'
      @trigger('open.overlay', arguments...)

  closed: (callback) =>
    if typeof callback is 'function'
      if @state() is 'closed'
        do callback
      else
        @$el.one('close.overlay', callback)

    else
      @state 'closed'
      @trigger('close.overlay', arguments...)

  off: =>
    super
    $('body').off('keydown', @checkKey)

  html: ->
    super
    @center()

  # Private

  center: ->
    top  = (@$el.height() / 2)
    left = (@$el.width() / 2)

    per = (($(window).height() / 10) * 2.5)
    if @$el.height() < ($(window).height() - per - 100)
      top += (per / 2)

    @$el.css(
      marginTop:  top * -1
      marginLeft: left * -1
    )

  checkClose: (e) =>
    if e.target is e.currentTarget
      e.preventDefault()
      @close()

  checkKey: (e) =>
    # Close on esc
    if e.keyCode is 27
      e.preventDefault()
      @close()

module.exports = Overlay