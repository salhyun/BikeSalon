# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200902025642) do

  create_table "bike_comment_ratings", force: :cascade do |t|
    t.integer  "rating"
    t.integer  "user_id"
    t.integer  "bike_comment_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["bike_comment_id"], name: "index_bike_comment_ratings_on_bike_comment_id"
    t.index ["user_id"], name: "index_bike_comment_ratings_on_user_id"
  end

  create_table "bike_comment_reports", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "bike_comment_id"
    t.integer  "report_item_id"
    t.text     "content"
    t.integer  "state"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "warned",          default: false
    t.index ["bike_comment_id"], name: "index_bike_comment_reports_on_bike_comment_id"
    t.index ["report_item_id"], name: "index_bike_comment_reports_on_report_item_id"
    t.index ["user_id"], name: "index_bike_comment_reports_on_user_id"
  end

  create_table "bike_comments", force: :cascade do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "motorbike_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "replyCount",   default: 0
    t.integer  "likeCount",    default: 0
    t.integer  "state",        default: 1
    t.index ["motorbike_id"], name: "index_bike_comments_on_motorbike_id"
    t.index ["user_id"], name: "index_bike_comments_on_user_id"
  end

  create_table "bike_comparisons", force: :cascade do |t|
    t.string   "bikeIds"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "viewCount",  default: 0
  end

  create_table "bike_ratings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "motorbike_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "design"
    t.integer  "performance"
    t.integer  "comfort"
    t.index ["motorbike_id"], name: "index_bike_ratings_on_motorbike_id"
    t.index ["user_id"], name: "index_bike_ratings_on_user_id"
  end

  create_table "bike_replies", force: :cascade do |t|
    t.text     "content"
    t.integer  "bike_comment_id"
    t.integer  "user_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "likeCount",       default: 0
    t.index ["bike_comment_id"], name: "index_bike_replies_on_bike_comment_id"
    t.index ["user_id"], name: "index_bike_replies_on_user_id"
  end

  create_table "bike_reply_ratings", force: :cascade do |t|
    t.integer  "rating"
    t.integer  "user_id"
    t.integer  "bike_reply_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["bike_reply_id"], name: "index_bike_reply_ratings_on_bike_reply_id"
    t.index ["user_id"], name: "index_bike_reply_ratings_on_user_id"
  end

  create_table "bike_reply_reports", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "bike_reply_id"
    t.integer  "report_item_id"
    t.text     "content"
    t.integer  "state"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "warned",         default: false
    t.index ["bike_reply_id"], name: "index_bike_reply_reports_on_bike_reply_id"
    t.index ["report_item_id"], name: "index_bike_reply_reports_on_report_item_id"
    t.index ["user_id"], name: "index_bike_reply_reports_on_user_id"
  end

  create_table "bikeyoutubes", force: :cascade do |t|
    t.integer  "motorbike_id"
    t.string   "title"
    t.string   "desc"
    t.string   "thumb"
    t.string   "videoId"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["motorbike_id"], name: "index_bikeyoutubes_on_motorbike_id"
  end

  create_table "brand_ratings", force: :cascade do |t|
    t.integer  "rating"
    t.integer  "user_id"
    t.integer  "brand_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_brand_ratings_on_brand_id"
    t.index ["user_id"], name: "index_brand_ratings_on_user_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.text     "desc"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "logo"
    t.string   "name_kr"
    t.float    "rating"
    t.datetime "newsUpdatedAt", default: '2020-08-21 00:55:40'
  end

  create_table "comment_ratings", force: :cascade do |t|
    t.integer  "rating"
    t.integer  "user_id"
    t.integer  "comment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_comment_ratings_on_comment_id"
    t.index ["user_id"], name: "index_comment_ratings_on_user_id"
  end

  create_table "comment_reports", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.integer  "report_item_id"
    t.text     "content"
    t.integer  "state"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "warned",         default: false
    t.index ["comment_id"], name: "index_comment_reports_on_comment_id"
    t.index ["report_item_id"], name: "index_comment_reports_on_report_item_id"
    t.index ["user_id"], name: "index_comment_reports_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "timeline_id"
    t.integer  "replyCount",  default: 0
    t.integer  "likeCount",   default: 0
    t.integer  "state",       default: 1
    t.index ["timeline_id"], name: "index_comments_on_timeline_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "comparison_comment_ratings", force: :cascade do |t|
    t.integer  "rating"
    t.integer  "user_id"
    t.integer  "comparison_comment_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["comparison_comment_id"], name: "index_comparison_comment_ratings_on_comparison_comment_id"
    t.index ["user_id"], name: "index_comparison_comment_ratings_on_user_id"
  end

  create_table "comparison_comment_reports", force: :cascade do |t|
    t.text     "content"
    t.integer  "state"
    t.integer  "user_id"
    t.integer  "comparison_comment_id"
    t.integer  "report_item_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "warned",                default: false
    t.index ["comparison_comment_id"], name: "index_comparison_comment_reports_on_comparison_comment_id"
    t.index ["report_item_id"], name: "index_comparison_comment_reports_on_report_item_id"
    t.index ["user_id"], name: "index_comparison_comment_reports_on_user_id"
  end

  create_table "comparison_comments", force: :cascade do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "bike_comparison_id"
    t.integer  "likeCount"
    t.integer  "replyCount"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "state",              default: 1
    t.index ["bike_comparison_id"], name: "index_comparison_comments_on_bike_comparison_id"
    t.index ["user_id"], name: "index_comparison_comments_on_user_id"
  end

  create_table "comparison_replies", force: :cascade do |t|
    t.text     "content"
    t.integer  "likeCount"
    t.integer  "user_id"
    t.integer  "comparison_comment_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["comparison_comment_id"], name: "index_comparison_replies_on_comparison_comment_id"
    t.index ["user_id"], name: "index_comparison_replies_on_user_id"
  end

  create_table "comparison_reply_ratings", force: :cascade do |t|
    t.integer  "rating"
    t.integer  "user_id"
    t.integer  "comparison_reply_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["comparison_reply_id"], name: "index_comparison_reply_ratings_on_comparison_reply_id"
    t.index ["user_id"], name: "index_comparison_reply_ratings_on_user_id"
  end

  create_table "comparison_reply_reports", force: :cascade do |t|
    t.text     "content"
    t.integer  "state"
    t.integer  "user_id"
    t.integer  "comparison_reply_id"
    t.integer  "report_item_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "warned",              default: false
    t.index ["comparison_reply_id"], name: "index_comparison_reply_reports_on_comparison_reply_id"
    t.index ["report_item_id"], name: "index_comparison_reply_reports_on_report_item_id"
    t.index ["user_id"], name: "index_comparison_reply_reports_on_user_id"
  end

  create_table "failurelogs", force: :cascade do |t|
    t.string   "kind"
    t.string   "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hashtags", force: :cascade do |t|
    t.integer  "searchCount",             default: 0, null: false
    t.integer  "useCount",                default: 0, null: false
    t.string   "word",        limit: 128
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "hashtags_timelines", id: false, force: :cascade do |t|
    t.integer "timeline_id", null: false
    t.integer "hashtag_id",  null: false
  end

  create_table "last_activities", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "refId"
    t.string   "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_last_activities_on_user_id"
  end

  create_table "livecasts", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "onair"
    t.string   "title"
    t.string   "category"
    t.string   "url"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "poster",     default: ""
    t.string   "streamkey",  default: ""
    t.index ["user_id"], name: "index_livecasts_on_user_id"
  end

  create_table "misc_archives", force: :cascade do |t|
    t.string   "kind"
    t.string   "content"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "state",      default: "updated"
  end

  create_table "motorbike_reports", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "motorbike_id"
    t.string   "specName"
    t.text     "content"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "state",        default: 1
    t.index ["motorbike_id"], name: "index_motorbike_reports_on_motorbike_id"
    t.index ["user_id"], name: "index_motorbike_reports_on_user_id"
  end

  create_table "motorbikes", force: :cascade do |t|
    t.string   "name",                    limit: 64
    t.string   "year",                    limit: 8
    t.integer  "style_id"
    t.string   "price",                   limit: 16
    t.integer  "brand_id"
    t.float    "totalRating"
    t.string   "maxpower",                limit: 64
    t.string   "maxtorque",               limit: 64
    t.string   "compression_ratio",       limit: 16
    t.string   "gasmileage",              limit: 32
    t.string   "valves",                  limit: 8
    t.string   "fuel_delivery_system",    limit: 64
    t.string   "fuel_type",               limit: 8
    t.string   "ignition_type"
    t.string   "cooling_system",          limit: 16
    t.string   "gearbox_type",            limit: 8
    t.string   "transmission_type",       limit: 8
    t.string   "clutch",                  limit: 128
    t.string   "front_brakes"
    t.string   "front_disk",              limit: 8
    t.string   "rear_disk",               limit: 8
    t.string   "front_tyre",              limit: 32
    t.string   "rear_tyre",               limit: 32
    t.string   "front_suspension"
    t.string   "rear_suspension"
    t.string   "dry_weight",              limit: 16
    t.string   "length",                  limit: 16
    t.string   "width",                   limit: 16
    t.string   "height",                  limit: 16
    t.string   "wheelbase",               limit: 16
    t.string   "seat_height",             limit: 16
    t.string   "fueltank",                limit: 16
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.string   "url"
    t.string   "rear_brakes"
    t.string   "top_speed",               limit: 16
    t.string   "curb_weight",             limit: 16
    t.string   "front_suspension_travel", limit: 16
    t.string   "rear_suspension_travel",  limit: 16
    t.string   "reserve_fuel",            limit: 16
    t.string   "engine_type",             limit: 64
    t.string   "engine_details"
    t.string   "camshaft",                limit: 64
    t.string   "exhaust_system",          limit: 128
    t.string   "lights"
    t.string   "frame_type",              limit: 128
    t.string   "final_drive",             limit: 32
    t.string   "lubrication_system",      limit: 128
    t.string   "bore_stroke",             limit: 32
    t.string   "co2_emissions",           limit: 32
    t.string   "emissions",               limit: 128
    t.string   "trail_size",              limit: 16
    t.string   "ground_clearance",        limit: 8
    t.string   "instruments"
    t.float    "displacement",                        default: 0.0
    t.integer  "msrp",                                default: 0
    t.float    "designRating",                        default: 0.0
    t.float    "performanceRating",                   default: 0.0
    t.float    "comfortRating",                       default: 0.0
    t.integer  "ratingCount",                         default: 0
    t.datetime "ytUpdatedAt",                         default: '2020-08-25 06:05:41'
    t.index ["brand_id"], name: "index_motorbikes_on_brand_id"
    t.index ["style_id"], name: "index_motorbikes_on_style_id"
  end

  create_table "mybikes", force: :cascade do |t|
    t.string   "name"
    t.text     "desc"
    t.string   "url"
    t.integer  "user_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "motorbike_id"
    t.string   "thumb"
    t.boolean  "public",         default: true
    t.integer  "subscribeCount", default: 0
    t.integer  "timelineCount",  default: 0
    t.index ["motorbike_id"], name: "index_mybikes_on_motorbike_id"
    t.index ["user_id"], name: "index_mybikes_on_user_id"
  end

  create_table "newslinks", force: :cascade do |t|
    t.integer  "brand_id"
    t.string   "title"
    t.string   "thumb"
    t.string   "url"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "desc",       default: ""
    t.index ["brand_id"], name: "index_newslinks_on_brand_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string   "kind"
    t.string   "content"
    t.integer  "fromRefId"
    t.integer  "toRefId"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "replies", force: :cascade do |t|
    t.text     "content"
    t.integer  "comment_id"
    t.integer  "user_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "likeCount",  default: 0
    t.index ["comment_id"], name: "index_replies_on_comment_id"
    t.index ["user_id"], name: "index_replies_on_user_id"
  end

  create_table "reply_ratings", force: :cascade do |t|
    t.integer  "rating"
    t.integer  "user_id"
    t.integer  "reply_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reply_id"], name: "index_reply_ratings_on_reply_id"
    t.index ["user_id"], name: "index_reply_ratings_on_user_id"
  end

  create_table "reply_reports", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "reply_id"
    t.integer  "report_item_id"
    t.text     "content"
    t.integer  "state"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "warned",         default: false
    t.index ["reply_id"], name: "index_reply_reports_on_reply_id"
    t.index ["report_item_id"], name: "index_reply_reports_on_report_item_id"
    t.index ["user_id"], name: "index_reply_reports_on_user_id"
  end

  create_table "report_items", force: :cascade do |t|
    t.string   "name"
    t.string   "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "salon_notices", force: :cascade do |t|
    t.string   "title"
    t.string   "kind"
    t.text     "content"
    t.string   "attachment", default: "", null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "sns_accounts", force: :cascade do |t|
    t.string   "kind"
    t.string   "uid"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sns_accounts_on_user_id"
  end

  create_table "styles", force: :cascade do |t|
    t.string   "name"
    t.text     "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "icon"
  end

  create_table "subscribe_mybikes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "mybike_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "readTimelineCount", default: 0
    t.index ["mybike_id"], name: "index_subscribe_mybikes_on_mybike_id"
    t.index ["user_id"], name: "index_subscribe_mybikes_on_user_id"
  end

  create_table "timeline_attachments", force: :cascade do |t|
    t.integer  "timeline_id"
    t.string   "kind"
    t.string   "name"
    t.string   "original"
    t.string   "thumb"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["timeline_id"], name: "index_timeline_attachments_on_timeline_id"
  end

  create_table "timeline_categories", force: :cascade do |t|
    t.string   "name"
    t.text     "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "color"
  end

  create_table "timeline_locations", force: :cascade do |t|
    t.integer  "timeline_id"
    t.float    "lat"
    t.float    "lng"
    t.string   "name"
    t.string   "address"
    t.string   "title"
    t.string   "category"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "likeCount",      default: "0"
    t.string   "cachedHashtags", default: ""
    t.index ["timeline_id"], name: "index_timeline_locations_on_timeline_id"
  end

  create_table "timeline_ratings", force: :cascade do |t|
    t.integer  "rating"
    t.integer  "user_id"
    t.integer  "timeline_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["timeline_id"], name: "index_timeline_ratings_on_timeline_id"
    t.index ["user_id"], name: "index_timeline_ratings_on_user_id"
  end

  create_table "timeline_reports", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "timeline_id"
    t.integer  "report_item_id"
    t.text     "content"
    t.integer  "state"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "warned",         default: false
    t.index ["report_item_id"], name: "index_timeline_reports_on_report_item_id"
    t.index ["timeline_id"], name: "index_timeline_reports_on_timeline_id"
    t.index ["user_id"], name: "index_timeline_reports_on_user_id"
  end

  create_table "timelines", force: :cascade do |t|
    t.string   "category"
    t.text     "desc"
    t.boolean  "public"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "mybike_id"
    t.string   "title"
    t.integer  "viewCount"
    t.integer  "user_id"
    t.integer  "commentCount",   default: 0
    t.integer  "likeCount",      default: 0
    t.integer  "kind",           default: 1
    t.string   "cachedHashtags", default: ""
    t.index ["mybike_id"], name: "index_timelines_on_mybike_id"
    t.index ["user_id"], name: "index_timelines_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "account"
    t.string   "password"
    t.string   "name"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "avatar"
    t.boolean  "verified",              default: false, null: false
    t.string   "secure_code",           default: ""
    t.string   "state",                 default: ""
    t.float    "exp",                   default: 0.0
    t.integer  "level",                 default: 0
    t.string   "titleOfLevel",          default: "뉴비"
    t.integer  "warningCount",          default: 0
    t.integer  "maxCountMybike",        default: 1
    t.integer  "maxCountTimelinePhoto", default: 3
    t.integer  "maxSizeTimelineVideo",  default: 10
    t.index ["account"], name: "index_users_on_account", unique: true
  end

end
