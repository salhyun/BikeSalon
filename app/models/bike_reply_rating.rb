class BikeReplyRating < ApplicationRecord
  belongs_to :user
  belongs_to :bike_reply
end
