require 'sprockets/cache/memcache_store'

module Brisk
  module Extensions
    module Assets extend self
      class UnknownAsset < StandardError; end

      module Helpers
        def asset_path(name)
          asset = settings.assets[name]
          raise UnknownAsset, "Unknown asset: #{name}" unless asset
          "#{settings.asset_host}/assets/#{asset.digest_path}"
        end

        def mobile_path(name)
          asset = settings.mobile[name]
          raise UnknownAsset, "Unknown asset: #{name}" unless asset
          "/mobile/#{asset.digest_path}"
        end
      end

      def registered(app)
        # Assets
        app.set :assets, assets = Sprockets::Environment.new(app.settings.root)

        assets.append_path('app/assets/javascripts')
        assets.append_path('app/assets/stylesheets')
        assets.append_path('app/assets/images')
        assets.append_path('vendor/assets/javascripts')

        Stylus.setup(assets)

        app.set :mobile, mobile = Sprockets::Environment.new(app.settings.root)

        mobile.append_path('app/mobile/javascripts')
        mobile.append_path('app/mobile/stylesheets')
        mobile.append_path('app/mobile/images')
        mobile.append_path('vendor/assets/javascripts')
        mobile.append_path('app/assets/javascripts')

        Stylus.setup(mobile)

        app.set :asset_host, ''

        app.configure :development do
          assets.cache = Sprockets::Cache::FileStore.new('./tmp')
          mobile.cache = Sprockets::Cache::FileStore.new('./tmp')
        end

        app.configure :staging do
          assets.cache = Sprockets::Cache::MemcacheStore.new
          mobile.cache = Sprockets::Cache::MemcacheStore.new
        end

        app.configure :production do
          assets.cache = Sprockets::Cache::MemcacheStore.new
          mobile.cache = Sprockets::Cache::MemcacheStore.new

          assets.js_compressor  = Closure::Compiler.new
          assets.css_compressor = YUI::CssCompressor.new
          mobile.js_compressor  = Closure::Compiler.new
          mobile.css_compressor = YUI::CssCompressor.new
        end

        app.helpers Helpers
      end
    end
  end
end