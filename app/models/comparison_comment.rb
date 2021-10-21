class ComparisonComment < ApplicationRecord
  belongs_to :user
  belongs_to :bike_comparison
  has_many :comparison_replies, dependent: :destroy
  has_many :comparison_comment_ratings, dependent: :destroy
  has_many :comparison_comment_reports, dependent: :destroy
end
