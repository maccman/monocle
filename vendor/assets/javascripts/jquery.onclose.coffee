$ = jQuery
$.activeTransforms = 0

addHandler = ->
  window.onbeforeunload or= ->
    '''There are some pending network requests which
       means closing the page may lose unsaved data.'''

removeHandler = ->
  window.onbeforeunload = null

$(document).ajaxSend (e, xhr, settings) ->
  return unless settings.warn
  $.activeTransforms += 1
  addHandler() if $.activeTransforms

$(document).ajaxComplete (e, xhr, settings) ->
  return unless settings.warn
  $.activeTransforms -= 1
  removeHandler() unless $.activeTransforms