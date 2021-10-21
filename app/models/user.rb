class User < ApplicationRecord
	has_many :mybikes, dependent: :destroy
	has_many :timelines, dependent: :destroy
	has_many :timeline_ratings, dependent: :destroy
	has_many :comments
	has_many :comment_ratings, dependent: :destroy
	has_many :comment_reports, dependent: :destroy
	has_many :replies
	has_many :reply_ratings, dependent: :destroy
	has_many :reply_reports, dependent: :destroy
	has_many :timeline_reports, dependent: :destroy
	has_many :subscribe_mybikes, dependent: :destroy
	has_many :bike_ratings, dependent: :destroy
	has_many :bike_comments
	has_many :bike_comment_ratings, dependent: :destroy
	has_many :bike_comment_reports, dependent: :destroy
	has_many :bike_replies
	has_many :bike_reply_ratings, dependent: :destroy
	has_many :bike_reply_reports, dependent: :destroy
	has_many :motorbike_reports, dependent: :destroy
	has_many :brand_ratings, dependent: :destroy
	has_many :notifications, dependent: :destroy
	has_many :comparison_comments
	has_many :comparison_comment_ratings, dependent: :destroy
	has_many :comparison_comment_reports, dependent: :destroy
	has_many :comparison_replies
	has_many :comparison_reply_ratings, dependent: :destroy
	has_many :comparison_comment_reports, dependent: :destroy
	has_one :last_activity, dependent: :destroy
	has_many :timeline_locations, through: :timelines
	has_one :livecast, dependent: :destroy
	# mount_uploader :avatar, AvatarUploader
end
