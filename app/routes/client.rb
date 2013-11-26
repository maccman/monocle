module Brisk
  module Routes
    class Client < Base
      helpers do
        def ios?
          request.user_agent =~ /iPhone|iPod/
        end

        alias_method :ios?, :mobile?

        def csrf_token
          Rack::CSRF.csrf_token(env)
        end

        set :spider do |enabled|
          condition do
            params.has_key?('_escaped_fragment_')
          end
        end

        mime_type :javascript, 'application/javascript'
        mime_type :cache_manifest, 'text/cache-manifest'
      end

      get '/assets/*' do
        env['PATH_INFO'].sub!(%r{^/assets}, '')
        settings.assets.call(env)
      end

      get '/mobile/manifest.appcache' do
        content_type :cache_manifest
        erb :mobile_manifest
      end

      get '/mobile/*' do
        env['PATH_INFO'].sub!(%r{^/mobile}, '')
        settings.mobile.call(env)
      end

      get '/setup.js' do
        content_type :javascript

        posts = fragment do
          Post.published.popular.limit(25).all
        end

        @options = {
          environment: settings.environment,
          csrfToken:   csrf_token,
          user:        current_user,
          posts:       ios? ? [] : posts,
          invite:      pending_invite
        }
        erb :setup
      end

      get '/', :spider => true do
        @posts = Post.published.popular.limit(30)
        erb :spider_list
      end

      get '/posts/:slug', :spider => true do
        @post = Post.first!(slug: params[:slug])
        erb :spider_page
      end

      get /\A((\/\Z)|\/posts)/ do
        if mobile?
          erb :mobile
        else
          erb :index
        end
      end
    end
  end
end