module Brisk
  module Extensions
    module Cache extend self
      def dalli
        @dalli ||= Dalli::Client.new
      end

      module Helpers
        def cache(key, options = {}, &block)
          return yield if settings.development? || settings.test?
          return yield if options[:enabled] == false
          Cache.dalli.fetch(key, options[:expires_in], &block)
        rescue ::Dalli::DalliError, Errno::ECONNREFUSED
          yield
        end

        def fragment(options = {}, &block)
          options = {
            key:        request.path,
            enabled:    !current_user?,
            expires_in: 30
          }.merge(options)

          cache(options[:key], options, &block)
        end
      end

      def registered(app)
        app.helpers Helpers
      end
    end
  end
end
