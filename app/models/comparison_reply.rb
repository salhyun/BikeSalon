class ComparisonReply < ApplicationRecord
  belongs_to :user
  belongs_to :comparison_comment
  has_many :comparison_reply_ratings, dependent: :destroy
  has_many :comparison_reply_reports, dependent: :destroy
end
