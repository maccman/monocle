module Brisk
  module Models
    class CommentVote < Sequel::Model
      one_to_one :comment
      one_to_one :user
    end
  end
end