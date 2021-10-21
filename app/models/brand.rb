class Brand < ApplicationRecord
  has_many :motorbikes
  has_many :brand_ratings
  has_many :newslinks
end
