$        = jQuery
helpers  = require('app/helpers')
Overlay  = require('app/controllers/overlay')
User     = require('app/models/user')
Post     = require('app/models/post')
State    = require('app/state')
PostItem = require('app/controllers/posts/item')

class Profile extends Overlay
  className: 'users-profile'
  helpers: helpers

  constructor: (@user) ->
    super()
    @on('click', '.item', @clickItem)
    @user.promise.done @render

  render: =>
    @html(@view('users/profile')(this))
    @$posts      = @$('.posts')
    @$votedPosts = @$('.voted-posts')

    @opened => @user.posts.all(@renderPosts)

  renderPosts: (posts) =>
    @$posts.empty()

    for post in posts
      @$posts.append(new PostItem(post: post).$el)

  clickItem: (e) =>
    @close()

module.exports = Profile