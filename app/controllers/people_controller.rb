class PeopleController < ApplicationController
  def show
    @person = Person.find(params[:id])
    @images = @person.user_images
  end
end
