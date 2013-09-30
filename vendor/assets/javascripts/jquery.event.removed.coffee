$ = jQuery

$.event.special.removed =
  remove: (e) -> e.handler?()