module Sequel
  module Plugins
    module URLValidationHelpers
      module InstanceMethods
        def validates_url(atts, opts = {})
          validatable_attributes(atts, opts.merge(:message => 'is an invalid url')) do |attribute, value, message|
            validation_error_message(message) unless valid_url?(value)
          end
        end

        private

        # a URL may be technically well-formed but may
        # not actually be valid, so this checks for both.
        def valid_url?(url)
          url = URI.parse(url) rescue false
          url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
        end
      end
    end
  end
end
