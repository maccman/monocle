$        = jQuery
$.gfx    = {}
$.gfx.fn = {}
$.fn.gfx = (method, args...) ->
  $.gfx.fn[method].apply(this, args)

div = document.createElement('div')

getVendorPropertyName = (prop) ->
  return prop if prop of div.style

  prefixes  = ['Moz', 'Webkit', 'O', 'ms']
  camelProp = prop.charAt(0).toUpperCase() + prop.substr(1)
  return prop if prop of div.style

  for prefix in prefixes
    vendorProp = prefix + camelProp
    return vendorProp if vendorProp of div.style

eventNames =
  'transition':       'transitionEnd',
  'MozTransition':    'transitionend',
  'OTransition':      'oTransitionEnd',
  'WebkitTransition': 'webkitTransitionEnd',
  'msTransition':     'MSTransitionEnd'

vendorNames = n =
  transition:      getVendorPropertyName('transition')
  transform:       getVendorPropertyName('transform')
  transformOrigin: getVendorPropertyName('transformOrigin')
  transitionEnd:   eventNames[getVendorPropertyName('transition')]
  supported:       !!getVendorPropertyName('transition')

$.support.transition or= vendorNames.supported

defaults =
  duration:   400
  queue:      true
  easing:     ''
  enabled:    $.support.transition
  properties: 'all'

transformTypes = [
  'scale', 'scaleX', 'scaleY', 'scale3d',
  'rotate', 'rotateX', 'rotateY', 'rotateZ', 'rotate3d',
  'translate', 'translateX', 'translateY', 'translateZ', 'translate3d',
  'skew', 'skewX', 'skewY',
  'matrix', 'matrix3d', 'perspective'
]

transformTypesPx  = ['translate', 'translateX', 'translateY', 'translateZ', 'translate3d']
transformTypesDeg = ['rotate', 'rotateX', 'rotateY']

unit = (i, units) ->
  if typeof i is 'string' and not i.match(/^[\-0-9\.]+$/)
    return i
  else
    return '' + i + units

transformProperty = (key, values) ->
  values = $.makeArray(values)

  for value, i in values
    if key in transformTypesPx
      values[i] = unit(value, 'px')

    else if key in transformTypesDeg
      values[i] = unit(value, 'deg')

  values.join(',')

emulateTransitionEnd = (duration) ->
  called = false
  $(@).one(n.transitionEnd, -> called = true)
  callback = => $(@).trigger(n.transitionEnd) unless called
  setTimeout(callback, duration)

# Public

$.gfx.fn.redraw = ->
  @each -> @offsetHeight

$.gfx.fn.queueNext = (callback, type = 'fx') ->
  @queue ->
    callback.apply(this, arguments)
    $(@).gfx('redraw')
    jQuery.dequeue(this, type)

# Helper function for easily adding transforms

$.gfx.fn.transform = (properties, options) ->
  options = $.extend({}, defaults, options)
  return this unless options.enabled

  transforms = []

  for key, value of properties when key in transformTypes
    value = transformProperty(key, value)
    transforms.push("#{key}(#{value})")
    delete properties[key]

  if transforms.length
    properties[n.transform] = transforms.join(' ')

  if options.origin
    properties[n.transformOrigin] = options.origin

  @css(properties)

$.gfx.fn.animate = (properties, options) ->
  if typeof options is 'function'
    options = complete: options

  options = $.extend({}, defaults, options)

  properties[n.transition] = [
    options.properties,
    unit(options.duration, 'ms'),
    options.easing
  ].join(' ')

  callback = ->
    $(@).css(n.transition, '')
    options.complete?.apply(this, arguments)
    $(@).dequeue() if options.queue

  @[ if options.queue is false then 'each' else 'queue' ] ->

    if options.enabled
      $(@).one(n.transitionEnd, callback)
      $(@).gfx('transform', properties)

      # Sometimes the event doesn't fire, so we have to fire it manually
      emulateTransitionEnd.call(this, options.duration + 50)

    else
      $(@).gfx('transform', properties)
      do callback