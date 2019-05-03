class User < ApplicationRecord
  has_many :user_images, :dependent => :destroy
  has_one :person_group, :dependent => :destroy

  def add_user_image(photo:, people:)
    user_image = UserImage.new
    user_image.people = people
    user_image.attach(photo)
    user_images << user_image
  end
end
