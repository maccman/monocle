$ = jQuery
$.support.touch or= ('ontouchstart' of window)

# Helper functions

parentIfText = (node) ->
  if 'tagName' of node then node else node.parentNode

swipeDirection = (x1, x2, y1, y2) ->
  xDelta = Math.abs(x1 - x2)
  yDelta = Math.abs(y1 - y2)

  if xDelta >= yDelta
    if x1 - x2 > 0 then 'Left' else 'Right'
  else
    if y1 - y2 > 0 then 'Up' else 'Down'

# jQuery helper functions

eventTypes = [
  'swipe'
  'swipeLeft'
  'swipeRight'
  'swipeUp'
  'swipeDown'
  'tap'
  'tapactive'
  'tapblur'
]

for type in eventTypes
  do (type) ->
    $.fn[type] = (callback) ->
      if typeof callback is 'function'
        @on(type, callback)
      else
        @trigger(type, arguments...)

# Options and events

events =
  start:  'touchstart'
  move:   'touchmove'
  end:    'touchend'
  cancel: 'touchcancel'

unless $.support.touch
  $.extend(events,
    start: 'mousedown'
    move:  'mousemove'
    end:   'mouseup'
  )

defaults =
  activeDelay: 100
  swipeOffset: 30

# jQuery touch plugin

$.fn.touch = (options = {}) ->
  options = $.extend({}, defaults, options)
  touch   = {}

  reset = ->
    clearTimeout(touch.activeTimeout)
    touch = {}

  @on events.start, (e) ->
    reset()

    e             = e.originalEvent
    eventTouch    = e.touches?[0]

    now           = Date.now()
    delta         = now - (touch.last or now)
    touch.target  = parentIfText(eventTouch?.target or e.target)
    touch.$target = $(touch.target)
    touch.x1      = eventTouch?.pageX or 0
    touch.y1      = eventTouch?.pageY or 0
    touch.last    = now

    touch.activeTimeout = setTimeout ->
      touch.$target.tapactive()
    , options.activeDelay

  @on events.move, (e) ->
    e          = e.originalEvent
    eventTouch = e.touches?[0]

    touch.x2   = eventTouch?.pageX or 0
    touch.y2   = eventTouch?.pageY or 0

    clearTimeout(touch.activeTimeout)
    touch.$target?.tapblur()

  @on events.end, (e) ->
    if touch.x2 > 0 or touch.y2 > 0

      # Trigger swipe
      if Math.abs(touch.x1 - touch.x2) > options.swipeOffset or
          Math.abs(touch.y1 - touch.y2) > options.swipeOffset

        direction = swipeDirection(touch.x1, touch.x2, touch.y1, touch.y2)
        touch.$target.swipe()
        touch.$target['swipe' + direction]()

      touch.x1 = touch.x2 = touch.y1 = touch.y2 = touch.last = 0

    else if 'last' of touch
      $target = touch.$target

      $target.tapblur()
      $target.tap()
      reset()

  @on events.cancel, ->
    touch.$target?.tapblur()
    reset()

# Apply to body

$ ->
  $('body').touch()

  $('body').on 'tapactive', '.tappable', (e) ->
    $(e.currentTarget).addClass('tappable-active')

  $('body').on 'tapblur', '.tappable', (e) ->
    $(e.currentTarget).removeClass('tappable-active')
