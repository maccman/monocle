$ = jQuery

defaults =
  offset: 0.7

$.fn.scrollHeight = ->
  this[0].scrollHeight

$.fn.infinite = (callback, options = {}) ->
  options = $.extend({}, defaults, options)
  pending = false

  @scroll =>
    if @scrollTop() + @innerHeight() >=
        @scrollHeight() * options.offset
      @trigger('scrolling.infinite')

  @on 'scrolling.infinite', scroll = =>
    return if pending
    pending = true

    request = callback.call(this)

    request.always =>
      pending = false

    request.fail =>
      @off 'scrolling.infinite', scroll

    request.done (data) =>
      if !data or data.length is 0
        @off 'scrolling.infinite', scroll

    @trigger 'loading.infinite'