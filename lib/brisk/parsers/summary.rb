require 'nokogiri'

module Brisk
  module Parsers
    module Summary extend self
      extend Encoding

      def parse(html)
        base = Nokogiri::HTML(html, nil, 'UTF-8')
        base.css('h1, h2, h3, h4, h5, pre, code').remove

        text = base.css('p')
        text = text.map {|p| encode(p.inner_text).strip }
        text = text.select {|t| t.length > 15 }
        text.join(' ')[0..900]
      end
    end
  end
end