class PeopleController < ApplicationController
  def show
    @person = Person.find(params[:id])
    @images = @person.user_images
    @friends = @person.relationships.map do |relationship| Person.find(relationship.friend_id) end
    @mutual_friends = get_mutual_friends(@person)
  end

  def get_mutual_friends(person)
    mutual_friends = []
    person.relationships.each do |relationship|
      friend = Person.find(relationship.friend_id)
      friend.relationships.each do |second_relationship|
        mutual_friend = Person.find(second_relationship.friend_id)
        if person != mutual_friend && !immediate_relationship(person, mutual_friend)
          puts "Person: #{person.name}(##{person.id}) and mutual friend: #{mutual_friend.name}(##{mutual_friend.id})"
          mutual_friends << mutual_friend
        end
      end
    end
    mutual_friends
  end

  def immediate_relationship(person, mutual_friend)
    (person.relationships.select do |relationship|
      relationship.friend_id == mutual_friend.id
    end)
        .size != 0
  end
end
