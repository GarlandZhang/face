class UserImage < ApplicationRecord
  belongs_to :user
  has_many :tags, :dependent => :destroy
  has_many :people, through: :tags
  has_one_attached :image, dependent: :destroy

  delegate :attach to: :image

  def names
    people.map { |person| person.name }
  end
end
