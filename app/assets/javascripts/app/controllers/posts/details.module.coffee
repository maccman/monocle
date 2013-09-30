$           = jQuery
Controller  = require('controller')
helpers     = require('app/helpers')
State       = require('app/state')
withUser    = State.withActiveUser

class Details extends Controller
  tag: 'header'
  className: 'wrap'
  helpers: helpers

  constructor: (options = {}) ->
    super

    @post = options.post or throw new Error('post required')

    @on 'click', '.vote', @clickVote
    @on 'mouseover', @prerender

    @render()
    @post.observe(@render)

  render: =>
    @html(@view('posts/details')(this))
    @$el.toggleClass('icon-present', !!@post.get('icon'))
    @$el.find('.icon img').error(@iconError)
    @prerenderTimout = setTimeout(@prerender, 2000)

  # Private

  clickVote: =>
    withUser (user) =>
      @post?.vote(user)

  navigate: (e) =>
    e.preventDefault()

    if e.metaKey
      @post.open()
    else
      @post.navigate()

  iconError: =>
    @$el.addClass('icon-error')

  prerender: =>
    return if @$prerender
    @$prerender = $('<link rel="prerender" />')
    @$prerender.attr('href', @post?.get('url'))
    @$el.append(@$prerender)

  release: =>
    super
    clearTimeout(@prerenderTimout)
    @post?.unobserve(@render)

module.exports = Details