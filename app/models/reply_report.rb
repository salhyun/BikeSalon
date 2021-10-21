class ReplyReport < ApplicationRecord
  belongs_to :user
  belongs_to :reply
  belongs_to :report_item
end
