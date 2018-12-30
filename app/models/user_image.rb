class UserImage < ApplicationRecord
  belongs_to :user
  has_many :tags
  has_many :people, through: :tags
end
