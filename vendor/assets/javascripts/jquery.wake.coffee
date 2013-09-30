$        = jQuery
TIMEOUT  = 20000
lastTime = (new Date()).getTime()

setInterval ->
  currentTime = (new Date()).getTime()

  # If timeout was paused (ignoring small
  # variations) then trigger the 'wake' event
  if currentTime > (lastTime + TIMEOUT + 2000)
    $(document).wake()

  lastTime = currentTime
, TIMEOUT

$.fn.wake = (callback) ->
  if typeof callback is 'function'
    $(this).on('wake', callback)
  else
    $(this).trigger('wake', arguments...)