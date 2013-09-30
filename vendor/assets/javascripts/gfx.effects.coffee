$ = jQuery

unless $.gfx
  throw new Error('GFX required')

$.gfx.fn.raisedIn = (options = {}) ->
  if typeof options is 'function'
    options = complete: options

  options = $.extend({}, duration: 300, options)

  $(@).gfx 'queueNext', ->
    $(@).gfx('transform', scale: 0.95, opacity: 0, translate3d: [0, 20, 0]).show()
  $(@).gfx('animate', scale: 1, opacity: 1, translate3d: [0, 0, 0], options)

$.gfx.fn.raisedOut = (options = {}) ->
  if typeof options is 'function'
    options = complete: options

  options = $.extend({}, duration: 200, options)

  $(@).gfx 'queueNext', ->
    $(@).gfx('transform', scale: 1, opacity: 1, translate3d: [0, 0, 0])
  $(@).gfx('animate', scale: 0.95, opacity: 0, translate3d: [0, 5, 0], options)

  $(@).gfx 'queueNext', ->
    $(@).hide().gfx('transform', scale: 1, opacity: 1, translate3d: [0, 0, 0])