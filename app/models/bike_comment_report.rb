class BikeCommentReport < ApplicationRecord
  belongs_to :user
  belongs_to :bike_comment
  belongs_to :report_item
end
