class Timeline < ApplicationRecord
  belongs_to :user
  belongs_to :mybike
  has_many :timeline_ratings, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :timeline_reports, dependent: :destroy
  has_many :timeline_attachments, dependent: :destroy
  has_one :timeline_location, dependent: :destroy
  has_and_belongs_to_many :hashtags #직접삭제
  # mount_uploaders :timelinepics, TimelinepicUploader
  # serialize :timelinepics, JSON
end
