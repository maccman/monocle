$ = jQuery

current = null

activeArea = (e) ->
  current?.data('active-area', false)
  current = $(e.currentTarget)
  current.data('active-area', true)

$.fn.isActiveArea = ->
  @data('active-area')

$.fn.activeArea = ->
  @click(activeArea)