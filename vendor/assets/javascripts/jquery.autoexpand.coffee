autoExpand = ->
  $el = $(this)
  $el.css(height: 'auto')
  $el.css(height: $el.scrollHeight())

$(document).on(
  'input',
  'textarea[autoexpand]',
  autoExpand
)