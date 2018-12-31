class User < ApplicationRecord
  has_many :user_images, dependent: :destroy
  has_one :person_group, dependent: :destroy
end
