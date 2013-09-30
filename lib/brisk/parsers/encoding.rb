module Brisk
  module Parsers
    module Encoding
      protected

      def encode(str)
        str = str.dup
        str.force_encoding 'UTF-8'
        str.gsub!("\xe2\x80\x9c", '"')
        str.gsub!("\xe2\x80\x9d", '"')
        str.gsub!("\xe2\x80\x98", "'")
        str.gsub!("\xe2\x80\x99", "'")
        str.gsub!("\xe2\x80\x93", "-")
        str.gsub!("\xe2\x80\x94", "--")
        str.gsub!("\xe2\x80\xa6", "...")

        str.encode(
          'UTF-8', 'binary',
          invalid: :replace,
          undef: :replace,
          replace: ''
        )
      end
    end
  end
end