Router = require('router')
State  = require('app/state')
Post   = require('app/models/post')

class AppRouter extends Router
  constructor: ->
    super
    @add '/', @routePosts
    @add '/posts/:slug', @routePost
    State.on 'view', @setView

  # Private

  setView: (view = 'posts') =>
    switch view
      when 'posts'
        @navigate '/'
      when 'comments'
        post = State.get('post')
        post and @navigate("/posts/#{post.get('slug')}")

  routePosts: =>
    State.toView 'posts', 'ltr'

  routePost: (params) =>
    post = Post.findBySlug(params.slug)
    State.set(post: post)
    State.toView 'comments'

module.exports = AppRouter