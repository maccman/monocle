require 'nokogiri'

module Brisk
  module Parsers
    module HTMLTitle extend self
      def parse(html)
        base  = Nokogiri::HTML(html, nil, 'UTF-8')
        title = base.css('title').first
        title && title.inner_text.strip
      end
    end
  end
end