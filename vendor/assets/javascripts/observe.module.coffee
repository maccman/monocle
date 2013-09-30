$ = jQuery

isDigit = (value) ->
  /^\d$/.test(value)

toArray = (value) ->
  Array::slice.call(value, 0)

createFragment = (value, element = document.createElement('div')) ->
  return value if value instanceof DocumentFragment
  range = document.createRange()
  range.setStart(element, 0)
  range.collapse(false)
  range.createContextualFragment(value)

ObjectObserve = (object, callback) ->
  object.observe?(-> callback(object))

ObjectUnobserve = (object, callback) ->
  object.unobserve?(-> callback(object))

exports.observe = observe = (object, callback) ->
  if typeof object isnt 'object'
    throw new Error('object required')

  nodes = []

  render = ->
    fragment = createFragment(callback(object))
    newNodes = (node for node in fragment.childNodes)
    parent   = nodes[0]?.parentNode

    if parent
      for newNode in newNodes
        parent.insertBefore newNode, nodes[0]

      for node in nodes
        parent.removeChild(node)

    nodes = newNodes
    fragment

  ObjectObserve(object, render)

  # Cleanup some objects
  elements = render()
  $(elements).children().one 'removed', ->
    ObjectUnobserve(object, render)

  do render

exports.observeEach = observeEach = (array, callback) ->
  fragment   = document.createDocumentFragment()
  arrayNodes = []
  arrayClone = toArray(array)

  add = (value, index) ->
    frag     = createFragment(callback(value))
    newNodes = (n for n in frag.childNodes)

    previousNode = arrayNodes[index - 1]
    previousNode = previousNode?[previousNode.length - 1]

    if parentNode = previousNode?.parentNode
      parentNode.insertBefore(frag, previousNode.nextSibling)
    else
      fragment.appendChild(frag)

    arrayNodes.splice(index, 0, newNodes)

    ObjectObserve(value, changeItem)
    $(frag).one 'removed', ->
      ObjectUnobserve(value, changeItem)

  remove = (value) ->
    index = arrayClone.indexOf(value)

    for node in arrayNodes[index]
      node.parentNode?.removeChild(node)

    arrayNodes.splice(index, 1)

  changeItem = (object) ->
    frag     = createFragment(callback(object))
    newNodes = (node for node in frag.childNodes)
    index    = arrayClone.indexOf(object)
    nodes    = arrayNodes[index]
    parent   = nodes[0]?.parentNode

    return unless parent

    for newNode in newNodes
      parent.insertBefore newNode, nodes[0]

    for node in nodes
      node.parentNode?.removeChild(node)

    arrayNodes[index] = newNodes

  changeArray = ->
    removed = ([item, i] for item, i in arrayClone when item not in array)
    added   = ([item, i] for item, i in array when item not in arrayClone)

    remove(args...) for args in removed
    add(args...) for args in added

    arrayClone = toArray(array)

  ObjectObserve array, changeArray
  add(object, i) for object, i in array
  fragment

exports.ObservedObject =
  observe: (callback) ->
    handlers = @hasOwnProperty('observeHandlers') and @observeHandlers or= []

    if typeof callback is 'function'
      handlers.push(callback)
    else
      args = arguments
      args = [[{object: this, type: 'updated'}]] unless args.length
      handle(args...) for handle in handlers

  unobserve: (callback) ->
    handlers = @hasOwnProperty('observeHandlers') and @observeHandlers or= []

    unless callback
      handlers.splice(0, handlers.length)
      return

    for cb, i in handlers when cb is callback
      handlers.splice(i, 1)