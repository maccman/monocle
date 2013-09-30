moment = require('moment')

moment.lang('en', {
  relativeTime : {
    future: "%s",
    past: "%s",
    s:  "now",
    m:  "1m",
    mm: "%dm",
    h:  "1h",
    hh: "%dh",
    d:  "1d",
    dd: "%dd",
    M:  ((n)->
      moment().subtract('months', 1).format('MM/YY')),
    MM: ((n)->
      moment().subtract('months', n).format('MM/YY')),
    y:  ((n)->
      moment().subtract('years', 1).format('MM/YY')),
    yy: ((n)->
      moment().subtract('years', n).format('MM/YY'))
  }
})

fromNow = (time, suffix) ->
  moment(time).fromNow(suffix)

escape = (value) ->
  ('' + value).replace(/&/g, '&amp;')
              .replace(/</g, '&lt;')
              .replace(/>/g, '&gt;')
              .replace(/\x22/g, '&quot;')

truncate = (str, length = 30, truncation = '...') ->
  return '' unless str
  return str unless str.length > length
  str.slice(0, length - truncation.length) + truncation

pluralize = (word, number = 1) ->
  word += 's' if number isnt 1
  word

crop = (url, width, height) ->
  url = url.replace(/^https?:\/\//, '')
  "//assets.example.com/crop/#{width}x#{height}/#{url}"

createFragment = (value, element = document.createElement('div')) ->
  return value if value instanceof DocumentFragment
  range = document.createRange()
  range.setStart(element, 0)
  range.collapse(false)
  range.createContextualFragment(value)

module.exports =
  fromNow: fromNow
  escape: escape
  truncate: truncate
  pluralize: pluralize
  crop: crop