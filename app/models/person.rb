class Person < ApplicationRecord
  belongs_to :person_group
  has_many :tags
  has_many :user_images, through: :tags
end
