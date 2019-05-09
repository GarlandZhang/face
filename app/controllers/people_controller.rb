require 'mini_magick'

class PeopleController < ApplicationController

  MAX_DEGREE = 3

  def search
    @user = User.find(params[:id])
    names = params[:names].split(',').map do |name| name.downcase end
    @people_found = @user.person_group.people.select do |person|
      puts "#{person.name}"
      (names.select do |name|
        person.name.downcase.include?(name)
      end).size() > 0
    end
  end

  def show
    @person = Person.find(params[:id])
    @person_group = PersonGroup.find(@person.person_group_id)
    @user = User.find(@person_group.user_id)
    @images = @person.user_images
    @avatar = @person.avatar
    puts "relationships: #{@person.relationships.to_a}"
    @friends_and_degrees = get_friends_upto(person: @person)
  end

  def edit
    @person = Person.find(params[:id])
  end

  def update
    @person = Person.find(params[:id])
    @person_group = PersonGroup.find(@person.person_group_id)
    @user = User.find(@person_group.user_id)
    @person.name = person_params[:name]
    if @person.save
      redirect_to controller: 'pages', action: 'dashboard', id: @user.id
    else
      puts "person could not be saved"
    end
  end

  private

  def person_params
    params.require(:person).permit(:name)
  end

  def get_friends_upto(person:, degree: MAX_DEGREE)
    degree_of_friends = {}
    cur_friends = [person]
    for cur_degree in 1..degree
      nth_degree_friends = (cur_friends.each_with_object([]) { |friend, nth_degree_friends| nth_degree_friends.concat mutual_friends(friend) }).uniq
      cur_friends = []
      nth_degree_friends.each do |friend|
        if degree_of_friends[friend].nil? && friend != person
          degree_of_friends[friend] = cur_degree
          cur_friends << friend
        end
      end
    end
    degree_of_friends
  end

  def mutual_friends(person)
    person.relationships.each_with_object([]) do |relationship, friends|
      friends << relationship.friend
    end
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
