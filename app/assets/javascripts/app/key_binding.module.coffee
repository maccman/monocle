$         = jQuery
State     = require('app/state')
PostBody  = require('app/controllers/posts/body')
Shortcuts = require('app/controllers/shortcuts')
NewPost   = require('app/controllers/posts/new')

class KeyBinding
  mapping:
    13:  'enterKey'
    37:  'leftKey'
    39:  'rightKey'
    78:  'nKey'
    82:  'rKey'
    85:  'uKey'
    191: 'questionKey'

  constructor: ->
    $(window).on('keydown', @keydown)

  # Private

  keydown: (e) =>
    # Return if input
    return if 'value' of e.target

    # Are we listening for this key?
    mapping = @[@mapping[e.which]]
    return unless mapping

    mapping(e)

  rKey: (e) =>
    return if e.metaKey or e.shiftKey
    return unless @getPost()

    e.preventDefault()
    PostBody.open(@getPost())

  uKey: (e) =>
    e.preventDefault()
    @getPost()?.vote(@getUser())

  rightKey: (e) =>
    return unless e.metaKey

    e.preventDefault()
    @getPost()?.navigate()

  enterKey: (e) =>
    e.preventDefault()

    if e.metaKey
      @getPost()?.open()
    else
      @getPost()?.navigate()

  questionKey: (e) =>
    return unless e.shiftKey
    e.preventDefault()

    Shortcuts.open()

  nKey: (e) =>
    e.preventDefault()
    NewPost.open()

  # Helpers

  getUser: =>
    State.get('user')

  getPost: =>
    State.get('post')

module.exports = KeyBinding