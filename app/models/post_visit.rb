module Brisk
  module Models
    class PostVisit < Sequel::Model
      one_to_one :post
      one_to_one :user
    end
  end
end