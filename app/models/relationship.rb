class Relationship < ApplicationRecord
  belongs_to :person, :class_name => 'Person', :foreign_key => 'person_id'
  belongs_to :friend, :class_name => 'Person', :foreign_key => 'friend_id'
end
