class PersonGroup < ApplicationRecord
  belongs_to :user
  has_many :people, :dependent => :destroy

  def existing_people(face_ids:, existing_ids:)
    existing_ids.each_with_object([]) do |existing_id, existing_people|
      candidates = existing_id['candidates']
      next if candidates.empty?
      candidate = candidates.first['personId']
      person = Person.find_by_person_id(candidate)
      current_face_id = existing_id['faceId']
      person.last_face_id = current_face_id
      face_ids.delete(current_face_id)
      existing_people << person
    end
  end

  def add_new_people(new_people)
    people_ids = people.map(&:person_id)
    new_people.each do |new_person|
      if people_ids.exclude? new_person.person_id
        people << new_person
      end
    end
  end
end
