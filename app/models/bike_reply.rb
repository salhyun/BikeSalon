class BikeReply < ApplicationRecord
  belongs_to :user
  belongs_to :bike_comment
  has_many :bike_reply_ratings, dependent: :destroy
  has_many :bike_reply_reports, dependent: :destroy
end
