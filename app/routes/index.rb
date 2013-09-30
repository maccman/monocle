module Brisk
  module Routes
    class Index < Sinatra::Application
      configure do
        set :views, 'app/views'
        set :root, File.expand_path('../../../', __FILE__)
        disable :method_override
        disable :static
        disable :protection
        set :erb, escape_html: true
      end

      def self.cache
        @cache ||= {}
      end

      helpers do
        def ios?
          request.user_agent =~ /iPhone|iPod/
        end

        def cache(key)
          self.class.cache[key] ||= yield
        end
      end

      use Rack::Protection::FrameOptions
      register Brisk::Extensions::Assets

      get /\A((\/\Z)|\/posts)/ do
        if ios?
          cache(:mobile) { erb :mobile }
        else
          cache(:index) { erb :index }
        end
      end
    end
  end
end