require 'nestful'
require 'nokogiri'

module Brisk
  module Parsers
    module OEmbed extend self
      def parse(html)
        base = Nokogiri::HTML(html, nil, 'UTF-8')
        link = base.css('link[type="application/json+oembed"]').first
        return unless link
        Nestful.get(link['href']).decoded
      end
    end
  end
end