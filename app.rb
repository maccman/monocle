require 'rubygems'
require 'bundler'

Bundler.require
$: << File.expand_path('../', __FILE__)
$: << File.expand_path('../lib', __FILE__)

require 'dotenv'
Dotenv.load

require 'sinatra/base'
require 'sinatra/sequel'
require 'sinatra/static_cache'
require 'active_support/json'
require 'stylus/sprockets'
require 'sprockets/commonjs'
require 'rack/session/dalli'
require 'rack/csrf'
require 'rediscloud'

require 'brisk/parsers'
require 'app/models'
require 'app/helpers'
require 'app/extensions'
require 'app/routes'

module Brisk
  class App < Sinatra::Application
    configure do
      set :database, lambda {
        ENV['DATABASE_URL'] ||
          "postgres://localhost:5432/monocle_#{environment}"
      }
    end

    configure do
      disable :method_override
      disable :static

      set :protection, except: :session_hijacking

      set :erb, escape_html: true

      set :sessions,
          :httponly     => true,
          :secure       => false,
          :expire_after => 5.years,
          :secret       => ENV['SESSION_SECRET']
    end

    configure do
      Mail.defaults do
        delivery_method :file
      end
    end

    use Rack::Deflater
    use Rack::CSRF

    use Brisk::Routes::Static
    use Brisk::Routes::Users
    use Brisk::Routes::Posts
    use Brisk::Routes::Comments
    use Brisk::Routes::Client
  end
end

# To easily access models in the console
include Brisk::Models
