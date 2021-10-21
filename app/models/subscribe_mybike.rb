class SubscribeMybike < ApplicationRecord
  belongs_to :user
  belongs_to :mybike
end
