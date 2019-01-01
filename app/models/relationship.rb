class Relationship < ApplicationRecord
  belongs_to :person, :foreign_key => 'main'
  belongs_to :person, :foreign_key => 'friend'
end
