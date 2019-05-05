class Person < ApplicationRecord
  belongs_to :person_group
  has_many :tags
  has_many :user_images, through: :tags
  has_many :relationships
  has_one_attached :avatar, dependent: :destroy

  def build_relationship(friend)
    return if in_relationship(friend) || self == friend
    relationships << Relationship.new(:friend => friend)
    friend.relationships << Relationship.new(:friend => self)
  end

  private

  def in_relationship(friend)
    relationships.any? { |relationship| relationship.friend == friend }
  end
end
