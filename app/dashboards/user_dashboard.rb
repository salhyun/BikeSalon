require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    mybikes: Field::HasMany,
    timelines: Field::HasMany,
    timeline_ratings: Field::HasMany,
    comments: Field::HasMany,
    comment_ratings: Field::HasMany,
    comment_reports: Field::HasMany,
    replies: Field::HasMany,
    reply_ratings: Field::HasMany,
    reply_reports: Field::HasMany,
    timeline_reports: Field::HasMany,
    subscribe_mybikes: Field::HasMany,
    bike_ratings: Field::HasMany,
    bike_comments: Field::HasMany,
    bike_comment_ratings: Field::HasMany,
    bike_comment_reports: Field::HasMany,
    bike_replies: Field::HasMany,
    bike_reply_ratings: Field::HasMany,
    bike_reply_reports: Field::HasMany,
    motorbike_reports: Field::HasMany,
    brand_ratings: Field::HasMany,
    notifications: Field::HasMany,
    comparison_comments: Field::HasMany,
    comparison_comment_ratings: Field::HasMany,
    comparison_comment_reports: Field::HasMany,
    comparison_replies: Field::HasMany,
    comparison_reply_ratings: Field::HasMany,
    last_activity: Field::HasOne,
    livecast: Field::HasOne,
    timeline_locations: Field::HasMany,
    id: Field::Number,
    account: Field::String,
    password: Field::String,
    name: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    avatar: Field::String,
    verified: Field::Boolean,
    secure_code: Field::String,
    state: Field::String,
    exp: Field::Number,
    level: Field::Number,
    titleOfLevel: Field::String,
    warningCount: Field::Number,
    maxCountMybike: Field::Number,
    maxCountTimelinePhoto: Field::Number,
    maxSizeTimelineVideo: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  id
  account
  name
  level
  titleOfLevel
  verified
  state
  warningCount
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  mybikes
  timelines
  timeline_ratings
  comments
  comment_ratings
  comment_reports
  replies
  reply_ratings
  reply_reports
  timeline_reports
  subscribe_mybikes
  bike_ratings
  bike_comments
  bike_comment_ratings
  bike_comment_reports
  bike_replies
  bike_reply_ratings
  bike_reply_reports
  motorbike_reports
  brand_ratings
  notifications
  comparison_comments
  comparison_comment_ratings
  comparison_comment_reports
  comparison_replies
  comparison_reply_ratings
  last_activity
  livecast
  timeline_locations
  id
  account
  password
  name
  created_at
  updated_at
  avatar
  verified
  secure_code
  state
  exp
  level
  titleOfLevel
  warningCount
  maxCountMybike
  maxCountTimelinePhoto
  maxSizeTimelineVideo
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  mybikes
  timelines
  timeline_ratings
  comments
  comment_ratings
  comment_reports
  replies
  reply_ratings
  reply_reports
  timeline_reports
  subscribe_mybikes
  bike_ratings
  bike_comments
  bike_comment_ratings
  bike_comment_reports
  bike_replies
  bike_reply_ratings
  bike_reply_reports
  motorbike_reports
  brand_ratings
  notifications
  comparison_comments
  comparison_comment_ratings
  comparison_comment_reports
  comparison_replies
  comparison_reply_ratings
  last_activity
  livecast
  timeline_locations
  account
  password
  name
  avatar
  verified
  secure_code
  state
  exp
  level
  titleOfLevel
  warningCount
  maxCountMybike
  maxCountTimelinePhoto
  maxSizeTimelineVideo
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(user)
  #   "User ##{user.id}"
  # end
end
