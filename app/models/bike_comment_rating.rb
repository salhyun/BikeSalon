class BikeCommentRating < ApplicationRecord
  belongs_to :user
  belongs_to :bike_comment
end
