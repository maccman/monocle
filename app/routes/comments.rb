module Brisk
  module Routes
    class Comments < Base
      get '/v1/comments/:id' do
        comment = Comment.first!(id: params[:id])
        json comment
      end

      post '/v1/comments/:id/vote', :auth => true do
        comment = Comment.first!(id: params[:id])
        comment.vote!(current_user)
        json comment
      end

      put '/v1/comments/:id', :auth => true do
        if current_user.admin?
          comment = Comment.first!(id: params[:id])
        else
          comment = Comment.for_user(current_user).first!(id: params[:id])
        end

        comment.update(body: params[:body])
        json comment
      end

      post '/v1/comments', :auth => true do
        comment      = Comment.new
        comment.user = current_user
        comment.set_fields(params, [:body, :parent_id, :post_id])

        comment.save!
        comment.vote!(comment.user)

        publish [:posts, :comments, :create],
                comment_id: comment.id,
                post_id: comment.post_id
        json comment
      end
    end
  end
end