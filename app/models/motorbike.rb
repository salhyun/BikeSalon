class Motorbike < ApplicationRecord
  belongs_to :brand
  belongs_to :style
  has_many :mybikes
  has_many :bike_ratings, dependent: :destroy
  has_many :bike_comments, dependent: :destroy
  has_many :motorbike_reports
  has_many :bikeyoutubes, dependent: :destroy
end
