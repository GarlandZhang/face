class Person < ApplicationRecord
  belongs_to :person_group
  has_many :tags
  has_many :user_images, through: :tags
  has_many :relationships
  has_one_attached :avatar
end
