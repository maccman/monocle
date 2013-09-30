$ = jQuery

# https://gist.github.com/hsablonniere/2581101
unless Element::scrollIntoViewIfNeeded
  Element::scrollIntoViewIfNeeded = (centerIfNeeded) ->
    centerIfNeeded = (if arguments.length is 0 then true else !!centerIfNeeded)
    parent = @parentNode
    parentComputedStyle = window.getComputedStyle(parent, null)
    parentBorderTopWidth = parseInt(parentComputedStyle.getPropertyValue("border-top-width"))
    parentBorderLeftWidth = parseInt(parentComputedStyle.getPropertyValue("border-left-width"))
    overTop = @offsetTop - parent.offsetTop < parent.scrollTop
    overBottom = (@offsetTop - parent.offsetTop + @clientHeight - parentBorderTopWidth) > (parent.scrollTop + parent.clientHeight)
    overLeft = @offsetLeft - parent.offsetLeft < parent.scrollLeft
    overRight = (@offsetLeft - parent.offsetLeft + @clientWidth - parentBorderLeftWidth) > (parent.scrollLeft + parent.clientWidth)
    alignWithTop = overTop and not overBottom
    parent.scrollTop = @offsetTop - parent.offsetTop - parent.clientHeight / 2 - parentBorderTopWidth + @clientHeight / 2  if (overTop or overBottom) and centerIfNeeded
    parent.scrollLeft = @offsetLeft - parent.offsetLeft - parent.clientWidth / 2 - parentBorderLeftWidth + @clientWidth / 2  if (overLeft or overRight) and centerIfNeeded
    @scrollIntoView alignWithTop  if (overTop or overBottom or overLeft or overRight) and not centerIfNeeded

$.fn.scrollIntoViewIfNeeded = ->
  @each -> @scrollIntoViewIfNeeded()

$.expr[":"].scrollable = (element) ->
  overflowX = $.css(element, 'overflowX')
  overflowY = $.css(element, 'overflowY')

  scrollTypes = ['auto', 'scroll']
  return true if overflowX in scrollTypes
  return true if overflowY in scrollTypes
  false

$.fn.preserveScroll = (callback) ->
  scrollTop  = @scrollTop()
  scrollLeft = @scrollLeft()
  callback.call(this)
  @scrollTop(scrollTop)
  @scrollLeft(scrollLeft)