class Reply < ApplicationRecord
  belongs_to :user
  belongs_to :comment
  has_many :reply_ratings, dependent: :destroy
  has_many :reply_reports, dependent: :destroy
end
