class UserImagesController < ApplicationController
  def new
    @user_image = UserImage.new
  end

  def create
    @user_image = UserImage.new(user_image_params)
    if @user_image.save
      redirect_to('/dashboard')
    end
  end

  private
  def user_image_params
    params.require(:user_image).permit(:url)
  end
end
