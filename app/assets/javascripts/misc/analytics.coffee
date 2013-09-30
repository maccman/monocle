$       = jQuery
State   = require('app/state')
Comment = require('app/models/comment')
Post    = require('app/models/post')

State.bind 'user', (user) ->
  return unless user
  profile = user.asJSON(all: true)

  # Extend with mixpanel vars
  $.extend profile,
    '$email':      profile.email
    '$created':    profile.created_at
    '$last_login': new Date
    '$name':       profile.name
    '$username':   profile.handle

  # Remove duplicate data
  delete profile.email
  delete profile.name
  delete profile.handle
  delete profile.created_at

  mixpanel?.track('users.authorized', profile)
  mixpanel?.identify(user.getID())
  mixpanel?.people.set(profile)

State.observeKey 'post', ->
  post = State.get('post')
  return unless post

  post.resolve ->
    mixpanel?.track('posts.active', post.asJSON())

Comment.on 'create', (comment) ->
  comment.resolve ->
    mixpanel?.track('comments.create', comment.asJSON())

Post.on 'create', (post) ->
  post.resolve ->
    mixpanel?.track('posts.create', post.asJSON())

Post.on 'vote', (post) ->
  mixpanel?.track('posts.vote', post.asJSON())