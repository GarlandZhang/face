class Person < ApplicationRecord
  belongs_to :person_group
  has_many :tags
  has_many :user_images, through: :tags
  has_many :relationships
  has_one_attached :avatar, dependent: :destroy

  def build_relationship(friend)
    return if in_relationship(friend)
    relationships << Relationship.new(:friend_id => friend.id)
    friend.relationships << Relationship.new(:friend_id => id)
  end

  private

  def in_relationship(friend)
    relationships.map(&:friend_id).include?(friend.id)
  end
end
