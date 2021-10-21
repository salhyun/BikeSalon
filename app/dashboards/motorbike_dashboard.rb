require "administrate/base_dashboard"

class MotorbikeDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    brand: Field::BelongsTo,
    style: Field::BelongsTo,
    mybikes: Field::HasMany,
    bike_ratings: Field::HasMany,
    bike_comments: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    year: Field::String,
    price: Field::String,
    msrp: Field::Number,
    totalRating: Field::Number.with_options(decimals: 2),
    displacement: Field::Number,
    maxpower: Field::String,
    maxtorque: Field::String,
    compression_ratio: Field::String,
    gasmileage: Field::String,
    valves: Field::String,
    fuel_delivery_system: Field::String,
    fuel_type: Field::String,
    ignition_type: Field::String,
    cooling_system: Field::String,
    gearbox_type: Field::String,
    transmission_type: Field::String,
    clutch: Field::String,
    front_brakes: Field::String,
    front_disk: Field::String,
    rear_disk: Field::String,
    front_tyre: Field::String,
    rear_tyre: Field::String,
    front_suspension: Field::String,
    rear_suspension: Field::String,
    dry_weight: Field::String,
    length: Field::String,
    width: Field::String,
    height: Field::String,
    wheelbase: Field::String,
    seat_height: Field::String,
    fueltank: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    url: Field::String,
    rear_brakes: Field::String,
    top_speed: Field::String,
    curb_weight: Field::String,
    front_suspension_travel: Field::String,
    rear_suspension_travel: Field::String,
    reserve_fuel: Field::String,
    engine_type: Field::String,
    engine_details: Field::String,
    camshaft: Field::String,
    exhaust_system: Field::String,
    lights: Field::String,
    frame_type: Field::String,
    final_drive: Field::String,
    lubrication_system: Field::String,
    bore_stroke: Field::String,
    co2_emissions: Field::String,
    emissions: Field::String,
    trail_size: Field::String,
    ground_clearance: Field::String,
    instruments: Field::String,
    designRating: Field::Number.with_options(decimals: 2),
    performanceRating: Field::Number.with_options(decimals: 2),
    comfortRating: Field::Number.with_options(decimals: 2),
    ratingCount: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  id
  year
  brand
  name
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  brand
  style
  mybikes
  bike_ratings
  bike_comments
  id
  name
  year
  price
  msrp
  totalRating
  designRating
  performanceRating
  comfortRating
  displacement
  maxpower
  maxtorque
  compression_ratio
  gasmileage
  valves
  fuel_delivery_system
  fuel_type
  ignition_type
  cooling_system
  gearbox_type
  transmission_type
  clutch
  front_brakes
  front_disk
  rear_disk
  front_tyre
  rear_tyre
  front_suspension
  rear_suspension
  dry_weight
  length
  width
  height
  wheelbase
  seat_height
  fueltank
  created_at
  updated_at
  url
  rear_brakes
  top_speed
  curb_weight
  front_suspension_travel
  rear_suspension_travel
  reserve_fuel
  engine_type
  engine_details
  camshaft
  exhaust_system
  lights
  frame_type
  final_drive
  lubrication_system
  bore_stroke
  co2_emissions
  emissions
  trail_size
  ground_clearance
  instruments
  ratingCount
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  brand
  style
  mybikes
  bike_ratings
  bike_comments
  name
  year
  price
  msrp
  totalRating
  designRating
  performanceRating
  comfortRating
  displacement
  maxpower
  maxtorque
  compression_ratio
  gasmileage
  valves
  fuel_delivery_system
  fuel_type
  ignition_type
  cooling_system
  gearbox_type
  transmission_type
  clutch
  front_brakes
  front_disk
  rear_disk
  front_tyre
  rear_tyre
  front_suspension
  rear_suspension
  dry_weight
  length
  width
  height
  wheelbase
  seat_height
  fueltank
  url
  rear_brakes
  top_speed
  curb_weight
  front_suspension_travel
  rear_suspension_travel
  reserve_fuel
  engine_type
  engine_details
  camshaft
  exhaust_system
  lights
  frame_type
  final_drive
  lubrication_system
  bore_stroke
  co2_emissions
  emissions
  trail_size
  ground_clearance
  instruments
  ratingCount
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

  # Overwrite this method to customize how motorbikes are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(motorbike)
  #   "Motorbike ##{motorbike.id}"
  # end
end
