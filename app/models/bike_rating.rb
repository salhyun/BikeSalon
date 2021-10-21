class BikeRating < ApplicationRecord
  belongs_to :user
  belongs_to :motorbike
end
