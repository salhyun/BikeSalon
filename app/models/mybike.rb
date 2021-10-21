class Mybike < ApplicationRecord
  belongs_to :motorbike
  belongs_to :user
  has_many :timelines, dependent: :destroy # dependent: destroy는 이 레코드가 삭제될때 여기에 속하는 모든 것들도 같이 삭제되는 옵션
  has_many :subscribe_mybikes, dependent: :destroy
  # mount_uploader :mybikepic, MybikepicUploader
end
