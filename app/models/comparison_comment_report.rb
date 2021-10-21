class ComparisonCommentReport < ApplicationRecord
  belongs_to :user
  belongs_to :comparison_comment
  belongs_to :report_item
end
