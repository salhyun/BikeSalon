require "administrate/base_dashboard"

class TimelineDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    mybike: Field::BelongsTo,
    timeline_ratings: Field::HasMany,
    comments: Field::HasMany,
    timeline_reports: Field::HasMany,
    timeline_attachments: Field::HasMany,
    timeline_location: Field::HasOne,
    id: Field::Number,
    category: Field::String,
    desc: Field::Text,
    public: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    title: Field::String,
    viewCount: Field::Number,
    commentCount: Field::Number,
    likeCount: Field::Number,
    kind: Field::Number,
    cachedHashtags: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  id
  user
  kind
  category
  title
  commentCount
  likeCount
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  user
  mybike
  timeline_ratings
  comments
  timeline_reports
  timeline_attachments
  timeline_location
  id
  kind
  category
  desc
  public
  created_at
  updated_at
  title
  viewCount
  commentCount
  likeCount
  cachedHashtags
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  user
  mybike
  timeline_ratings
  comments
  timeline_reports
  timeline_attachments
  timeline_location
  kind
  category
  desc
  public
  title
  viewCount
  commentCount
  likeCount
  cachedHashtags
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

  # Overwrite this method to customize how timelines are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(timeline)
  #   "Timeline ##{timeline.id}"
  # end
end
