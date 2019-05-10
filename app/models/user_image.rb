class UserImage < ApplicationRecord
  belongs_to :user
  has_many :tags, :dependent => :destroy
  has_many :object_tags, :dependent => :destroy
  has_many :people, through: :tags
  has_one_attached :image, dependent: :destroy

  delegate :attach, to: :image

  def names
    names = []
    people.each { |person| names << person.name }
    object_tags.each { |tag| names << tag.name }
    names
  end
end
