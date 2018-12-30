class UserImagesController < ApplicationController
  def new
    @user = User.find(params[:id])
    @user_image = UserImage.new
  end

  def create
    @user = User.find(params[:id])
    @user.user_images.new(user_image_params)
    if @user.save
      redirect_to controller: 'pages', action: 'dashboard', id: @user.id
    else
      puts "ERROR"
    end
  end

  private
  def user_image_params
    params.require(:user_image).permit(:url)
  end
end
