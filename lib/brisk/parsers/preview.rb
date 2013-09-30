require 'nokogiri'

module Brisk
  module Parsers
    module Preview extend self
      def parse(html)
        base = Nokogiri::HTML(html, nil, 'UTF-8')
        parse_meta_image(base) || parse_image(base)
      end

      protected

      def parse_meta_image(base)
        image = base.at_css('meta[property="og:image"], meta[itemprop="image"]')
        image && image['content']
      end

      def parse_image(base)
        image = base.at_css('img')
        return unless image

        # WP-Lazy-Load plugin
        if src = image['data-lazy-src']
          return src
        end

        # Lazy Load Plugin for jQuery
        if src = image['data-original']
          return src
        end

        # LazyLoad-plugin
        if src = image['data-src']
          return src
        end

        image['src']
      end
    end
  end
end