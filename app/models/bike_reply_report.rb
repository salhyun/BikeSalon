class BikeReplyReport < ApplicationRecord
  belongs_to :user
  belongs_to :bike_reply
  belongs_to :report_item
end
