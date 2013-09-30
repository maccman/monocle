Stream  = require('stream')
Session = require('session')
Post    = -> require('app/models/post')
Comment = -> require('app/models/comment')

class ModelStream extends Stream
  url: 'http://stream.example.com/subscribe'

  constructor: ->
    super

    @on 'setup', (id) ->
      Session.setStreamID(id)

    @on 'posts:create', (r) ->
      post = Post().find(r.id, remote: true)
      Post().newest.add(post.promise)

    @on 'posts:vote', (r) ->
      Post().find(r.id, remote: true)

    @on 'posts:comments:create',  (r) ->
      comment = Comment().find(r.comment_id, remote: true)
      Post().find(r.post_id).comments.add(comment.promise)

module.exports = ModelStream