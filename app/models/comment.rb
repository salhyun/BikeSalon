class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :timeline
  has_many :comment_ratings, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :comment_reports, dependent: :destroy
end
