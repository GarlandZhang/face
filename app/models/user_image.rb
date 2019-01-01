class UserImage < ApplicationRecord
  belongs_to :user
  has_many :tags, :dependent => :destroy
  has_many :people, through: :tags
end
