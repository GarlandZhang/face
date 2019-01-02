class PeopleController < ApplicationController
  def show
    @person = Person.find(params[:id])
    @images = @person.user_images
    @friends = @person.relationships.map do |relationship| Person.find(relationship.friend_id) end
    @second_friends = get_second_friends(@person)
    @hash_mutual_friends = get_hashed_mutual_friends(@person)
  end

  def get_second_friends(person)
    second_friends = []
    person.relationships.each do |relationship|
      friend = Person.find(relationship.friend_id)
      friend.relationships.each do |second_relationship|
        second_friend = Person.find(second_relationship.friend_id)
        if person != second_friend && !immediate_relationship(person, second_friend)
          puts "Person: #{person.name}(##{person.id}) and second friend: #{second_friend.name}(##{second_friend.id})"
          second_friends << second_friend
        end
      end
    end
    second_friends
  end

  def get_hashed_mutual_friends(person)
    hash_mutual_friends = []
    @person.relationships.each do |relationship|
      hash_mutual_friends[relationship.friend_id] = get_mutual_friends(person, Person.find(relationship.friend_id))
    end
    hash_mutual_friends
  end

  def get_mutual_friends(person1, person2)
    mutual_friends = []
    person1.relationships.each do |relationship1|
      person2.relationships.each do |relationship2|
        if relationship1.friend_id != person2.id &&
            relationship2.friend_id != person1.id &&
            relationship1.friend_id == relationship2.friend_id
          mutual_friends << Person.find(relationship1.friend_id)
        end
      end
    end
    mutual_friends
  end

  def immediate_relationship(person, second_friend)
    (person.relationships.select do |relationship|
      relationship.friend_id == second_friend.id
    end)
        .size != 0
  end
end
