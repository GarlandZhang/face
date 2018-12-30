class UserImagesController < ApplicationController
  def new
    @user = User.find(params[:id])
    @user_image = UserImage.new
  end

  def create
    @user = User.find(params[:id])
    #TODO: fix form input
    @urls = user_image_params[:url].split(',')

    @urls.each do |url|
      @user.user_images.new({:url => url})
    end

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
