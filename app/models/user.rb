class User < ApplicationRecord
  has_many :user_images
  has_one :person_group
end
