class ComparisonReplyRating < ApplicationRecord
  belongs_to :user
  belongs_to :comparison_reply
end
