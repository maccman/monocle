$                = jQuery
CSRF_HEADER      = 'X-CSRF-Token'
STREAM_ID_HEADER = 'X-Stream-ID'

# We need to include a CSRF token with every http request
exports.setCSRFToken = (securityToken) ->
  $.ajaxPrefilter (options, _, xhr) ->
    unless xhr.crossDomain
      xhr.setRequestHeader(CSRF_HEADER, securityToken)

exports.setStreamID = (streamID) ->
  $.ajaxPrefilter (options, _, xhr) ->
    unless xhr.crossDomain
      xhr.setRequestHeader(STREAM_ID_HEADER, streamID)