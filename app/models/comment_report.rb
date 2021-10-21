class CommentReport < ApplicationRecord
  belongs_to :user
  belongs_to :comment
  belongs_to :report_item
end
