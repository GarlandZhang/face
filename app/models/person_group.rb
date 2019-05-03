class PersonGroup < ApplicationRecord
  belongs_to :user
  has_many :people, :dependent => :destroy

  def add_new_people(new_people)
    people_ids = people.map(&:person_id)
    new_people.each do |new_person|
      if people_ids.exclude? new_person.person_id
        people << new_person
      end
      puts "new_person: #{new_person} | people_ids: #{people_ids}"
    end
    puts "people_ids: #{people_ids} | new_people: #{new_people}"
  end
end
