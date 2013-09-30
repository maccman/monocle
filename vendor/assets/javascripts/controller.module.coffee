$ = jQuery

class Controller
  tag: 'div'
  helpers: {}

  constructor: (@options = {}) ->
    @el  = @el or @options.el or document.createElement(@tag)
    @$el = $(@el)
    @$el.addClass(@className)
    @on('removed', @release)

  $: (sel) ->
    $(sel, @$el)

  on: ->
    @$el.on(arguments...)

  trigger: ->
    @$el.trigger(arguments...)

  append: (controller) ->
    @$el.append(controller.el or controller)

  html: (controller) ->
    @$el.html(controller.el or controller)

  setElement: ($el) ->
    @$el = $($el).replaceAll(@$el)

  view: (name) =>
    (context = {}) =>
      context.view    = @view
      context.helpers = @helpers
      @template(name)(context)

  template: (name) ->
    JST["app/views/#{name}"]

  off: ->
    @$el.off(arguments...)

  release: =>

module.exports = Controller