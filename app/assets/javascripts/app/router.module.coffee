Router = require('router')
State  = require('app/state')
Post   = require('app/models/post')

class AppRouter extends Router
  constructor: ->
    super
    @add '/', @routeIndex
    @add '/posts/:slug', @routePost
    State.change 'post', @navigatePost

  routeIndex: =>
    State.set(post: null)

  routePost: (params) =>
    post = Post.findBySlug(params.slug)
    State.set(post: post)

  navigatePost: (post) =>
    if post and post.get('slug')
      @navigate "/posts/#{post.get('slug')}"
    else
      @navigate '/'

    if title = post?.get('title')
      document.title = title

module.exports = AppRouter