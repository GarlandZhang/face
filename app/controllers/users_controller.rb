class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to controller: 'pages', action: 'dashboard', id: @user.id
    end
  end

  private
    def user_params
      params.required(:user).permit(:username)
    end
end
