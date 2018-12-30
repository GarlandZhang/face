class Tag < ApplicationRecord
  belongs_to :user_image
  belongs_to :person
end
