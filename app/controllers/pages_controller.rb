class PagesController < ApplicationController
  def login
    redirect_to '/users/new'
  end

  def dashboard
    @user = User.find(params[:id])
  end
end
