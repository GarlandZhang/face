class PagesController < ApplicationController
  def login
    redirect_to '/users/new'
  end

  def dashboard
    @user = User.find(params[:id])
    @images = @user.user_images || []
    @person_group = @user.person_group
    @people = @person_group.people || []
  end
end
