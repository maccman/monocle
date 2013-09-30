require 'nokogiri'

module Brisk
  module Parsers
    module LinkIcon extend self
      def parse(html)
        base = Nokogiri::HTML(html, nil, 'UTF-8')
        parse_icons(base)
      end

      protected

      def parse_icons(base)
        icons = base.css('link[rel=apple-touch-icon], link[rel=apple-touch-icon-precomposed]')

        icons.map do |i|
          sizes = i['sizes'] && parse_sizes(i['sizes'])
          type  = precomposed?(i['href']) ? :icon_precomposed : :icon

          {
            :type   => type,
            :href   => i['href'],
            :sizes  => i['sizes'],
            :width  => sizes && sizes[0],
            :height => sizes && sizes[1],
          }
        end
      end

      def parse_images(base)
        images = base.css('link[rel=apple-touch-startup-image]')

        images.map do |i|
          {
            :type => :image,
            :href => i['href']
          }
        end
      end

      def precomposed?(href)
        href =~ /precomposed/
      end

      def parse_sizes(sizes)
        [$1.to_i, $2.to_i] if sizes =~ /(\d+)x(\d+)/
      end
    end
  end
end