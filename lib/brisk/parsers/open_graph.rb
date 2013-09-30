require 'nokogiri'

module Brisk
  module Parsers
    module OpenGraph extend self
      PROPERTIES = %w{description title url site_name type image}

      def parse(html)
        base = Nokogiri::HTML(html, nil, 'UTF-8')
        PROPERTIES.inject({}) do |hash, property|
          hash[property.to_sym] = parse_property(property, base)
          hash
        end
      end

      protected

      def parse_property(property, base)
        description = base.css("meta[property=\"og:#{property}\"]").first
        content     = description && description['content']
        content && content.strip
      end
    end
  end
end
