class Relationship < ApplicationRecord
  belongs_to :person, :foreign_key => 'person_id'
  belongs_to :person, :foreign_key => 'friend_id'
end
