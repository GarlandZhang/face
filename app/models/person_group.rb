class PersonGroup < ApplicationRecord
  belongs_to :user
  has_many :people, :dependent => :destroy

  def add_new_people(new_people)
    people_ids = people.map(&:person_id)
    new_people.each do |new_person|
      if people_ids.exclude? new_person.person_id
        people << new_person
      end
    end
    normalize_people(new_people) # mutation
  end

  private

  def normalize_people(people)
    for main in 0..people.size - 1
      for friend in (main + 1)..people.size - 1
        people[main].build_relationship(people[friend]) if main != friend
      end
    end
    people
  end
end
