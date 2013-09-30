module Brisk
  module Routes
    class Base < Sinatra::Application
      configure do
        set :views, 'app/views'
        set :root, File.expand_path('../../../', __FILE__)

        disable :method_override
        disable :protection
        disable :static
        set :erb, escape_html: true

        # Exceptions
        enable :use_code
        set :show_exceptions, :after_handler
      end

      register Extensions::API
      register Extensions::Assets
      register Extensions::Auth
      register Extensions::Cache

      error Sequel::ValidationFailed do
        status 406
        json error: {
          type: 'validation_failed',
          messages: env['sinatra.error'].errors
        }
      end

      error Sequel::NoMatchingRow do
        status 404
        json error: {type: 'unknown_record'}
      end
    end
  end
end