$ = jQuery

current = null

activeArea = (e) ->
  current = $(e.currentTarget)

$.fn.isActiveArea = ->
  @is(current)

$.fn.activeArea = ->
  @click(activeArea)