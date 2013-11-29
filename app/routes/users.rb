module Brisk
  module Routes
    class Users < Base
      get '/auth/:platform/callback' do
        self.current_user = User.from_auth!(env['omniauth.auth'])

        if pending_invite
          current_user.activate!(pending_invite)
          self.pending_invite = nil
        end

        erb :authorized
      end

      get '/auth/failure' do
        session.destroy
        halt 422, 'Auth failure'
      end

      get '/logout' do
        session.destroy
        redirect '/'
      end

      get '/v1/users/current' do
        error 404 unless current_user?
        json current_user
      end

      post '/v1/users/current', :auth => :user do
        current_user.update_fields(params, [:manifesto])
        json current_user
      end

      post '/v1/users/register', :auth => :user do
        current_user.email = params[:email]
        current_user.registered = true
        current_user.save!
        json current_user
      end

      get '/v1/users/:id/posts' do
        user = User.first!(id: params[:id])
        json user.posts_dataset.ordered
      end

      get '/v1/users/:id/voted_posts' do
        user = User.first!(id: params[:id])
        json user.voted_posts_dataset.ordered
      end

      get '/v1/users/:id' do
        user = User.first!(id: params[:id])
        json user
      end

      post '/v1/users/invite', :auth => true do
        unless current_user.admin?
          unless current_user.invites_count > 0
            error 422
          end

          current_user.decrement_invites!
        end

        invite = UserInvite.new(
          email:   params[:email],
          twitter: params[:twitter],
          github:  params[:github]
        )
        invite.user = current_user
        invite.save!

        # Do nothing, already using
        if invite.active_matching_user
          halt 200

        # User has already signed up, but not activated
        elsif user = invite.pending_matching_user
          user.activate!(invite)
          user.notify_activate!

        # We haven't sent them an invite already
        elsif !invite.similar_invite
          invite.notify!
        end

        200
      end

      post '/v1/feedback' do
        unless params[:text].present?
          error 422
        end

        Mailer.feedback!(
          params[:text],
          params[:email]
        )
        200
      end

      get '/claim/:code' do
        invite = UserInvite.pending[code: params[:code]]
        self.pending_invite = invite
        redirect '/'
      end
    end
  end
end