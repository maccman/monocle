$ = jQuery

$.fn.redraw or= ->
  $(this).each ->
    this.offsetHeight

$.support.transition or= do ->
  style = (new Image).style
  'webkitTransition' of style