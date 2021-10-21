class ComparisonCommentRating < ApplicationRecord
  belongs_to :user
  belongs_to :comparison_comment
end
