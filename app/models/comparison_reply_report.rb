class ComparisonReplyReport < ApplicationRecord
  belongs_to :user
  belongs_to :comparison_reply
  belongs_to :report_item
end
