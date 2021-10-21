class TimelineReport < ApplicationRecord
  belongs_to :user
  belongs_to :timeline
  belongs_to :report_item
end
