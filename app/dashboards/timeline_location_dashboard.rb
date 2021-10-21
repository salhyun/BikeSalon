require "administrate/base_dashboard"

class TimelineLocationDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    timeline: Field::BelongsTo,
    id: Field::Number,
    lat: Field::Number.with_options(decimals: 2),
    lng: Field::Number.with_options(decimals: 2),
    name: Field::String,
    address: Field::String,
    title: Field::String,
    category: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    likeCount: Field::Number,
    cachedHashtags: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  id
  lat
  lng
  title
  address
  likeCount
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  timeline
  id
  lat
  lng
  name
  address
  title
  category
  created_at
  updated_at
  likeCount
  cachedHashtags
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  timeline
  lat
  lng
  name
  address
  title
  category
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

  # Overwrite this method to customize how timeline locations are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(timeline_location)
  #   "TimelineLocation ##{timeline_location.id}"
  # end
end
