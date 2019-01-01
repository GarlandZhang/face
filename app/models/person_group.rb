class PersonGroup < ApplicationRecord
  belongs_to :user
  has_many :people, :dependent => :destroy
end
