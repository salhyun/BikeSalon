class BikeComment < ApplicationRecord
  belongs_to :user
  belongs_to :motorbike
  has_many :bike_comment_ratings, dependent: :destroy
  has_many :bike_replies, dependent:  :destroy
  has_many :bike_comment_reports, dependent: :destroy
end
