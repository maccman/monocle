module Brisk
  module Extensions
    module Auth extend self
      module Helpers
        def pending_invite
          invite_id = session[:pending_invite_id]
          invite_id && UserInvite[invite_id]
        end

        def pending_invite=(invite)
          session[:pending_invite_id] = invite && invite.id
        end

        def current_user_from_session
          user_id = session[:user_id]
          user_id && User[user_id]
        end

        def current_user_from_header
          request = Rack::Auth::AbstractRequest.new(env)
          return unless request.provided?

          case request.scheme
          when :bearer
            token = request.params
          when :basic
            auth    = Rack::Auth::Basic::Request.new(env)
            token = auth.credentials[0]
          end

          token && User[secret: token]
        end

        def current_user=(user)
          session[:user_id] = user && user.id
        end

        def current_user
          @current_user ||= current_user_from_session
        end

        def current_user?
          !!current_user
        end
      end

      def registered(app)
        app.set :twitter_key, ENV['TWITTER_KEY']
        app.set :twitter_secret, ENV['TWITTER_SECRET']

        app.set :github_key, ENV['GITHUB_KEY']
        app.set :github_secret, ENV['GITHUB_SECRET']

        app.use OmniAuth::Builder do
          provider :twitter,
                   app.twitter_key,
                   app.twitter_secret,
                   :secure_image_url => true

          provider :github,
                   app.github_key,
                   app.github_secret
        end

        app.set(:auth) do |type|
          condition do
            error 403 unless current_user?
            error 403 if type == :admin && !current_user.admin?
          end
        end

        app.helpers Helpers
      end
    end
  end
end