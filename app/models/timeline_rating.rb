class TimelineRating < ApplicationRecord
  belongs_to :user
  belongs_to :timeline
end
