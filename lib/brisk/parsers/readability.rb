# encoding: utf-8

require 'nokogiri'

module Brisk
  module Parsers
    module Readability extend self
      extend Encoding

      NEGATIVE = /(comment|meta|footer|footnote)/
      POSITIVE = /((^|\\s)(post|hentry|entry[-]?(content|text|body)?|article[-]?(content|text|body)?)(\\s|$))/

      def parse(html)
        base = Nokogiri::HTML(encode(html), nil, 'UTF-8')
        parse_paragraph_tags(base)
      end

      protected

      def parse_paragraph_tags(base)
        articles = base.css('p').map(&:parent).uniq

        articles = articles.inject({}) do |hash, article|
          hash[article] = score(article)
          hash
        end

        article, score = articles.sort_by {|k,v| v }.last
        return unless article
        return unless score > 10

        article.css('script, style, link, iframe').remove

        article.inner_html
      end

      def score(article)
        score = 0

        score -= 50 if article.attr('class') =~ NEGATIVE
        score -= 50 if article.attr('id') =~ NEGATIVE

        score += 25 if article.attr('class') =~ POSITIVE
        score += 25 if article.attr('id') =~ POSITIVE

        score += 25 if article.name == 'article'

        paragraphs = article.css('> p')

        score += 2 if paragraphs.text.length > 10
        score += paragraphs.text.split(',').length
        score += paragraphs.length

        score
      end
    end
  end
end