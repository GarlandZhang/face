require 'net/http'

class UserImagesController < ApplicationController
  def new
    @user = User.find(params[:id])
    @user_image = UserImage.new
  end

  def create
    @user = User.find(params[:id])
    #TODO: fix form input
    urls = user_image_params[:url].split(',')

    # for each url, detect and add to list of images
    urls.each do |url|
      faces = detect_faces(url)

      #@user.user_images.new({:url => url})
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

  def detect_faces(user_image)
    uri = URI('https://westcentralus.api.cognitive.microsoft.com/face/v1.0/detect')
    uri.query = URI.encode_www_form({
        # Request parameters
        'returnFaceId' => 'true',
        'returnFaceLandmarks' => 'false',
    })

    request = Net::HTTP::Post.new(uri.request_uri)
  # Request headers
    request['Content-Type'] = 'application/json'
  # Request headers
    request['Ocp-Apim-Subscription-Key'] = 'c48485623e4548bd958b7d526c535fb3'
  # Request body
    request.body = "{\"url\": \"#{user_image}\"}"

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
    end

    response.body
  end
end
