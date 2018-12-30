require 'net/http'

class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    #TODO: make sure unique username

    create_person_group
    if @user.save
      redirect_to controller: 'pages', action: 'dashboard', id: @user.id
    end
  end

  private
  def user_params
    params.required(:user).permit(:username)
  end

  def create_person_group
    username = @user.username
    azure_group_id = "person_group_#{username}"
    group_name = "#{username}_image_collection"
    create_azure_person_group(azure_group_id, group_name)
    @user.person_group = PersonGroup.new({:azure_id => azure_group_id, :name => group_name})
  end

  def create_azure_person_group(azure_group_id, group_name)

    uri = URI("https://westcentralus.api.cognitive.microsoft.com/face/v1.0/persongroups/#{azure_group_id}}")

    request = Net::HTTP::Put.new(uri.request_uri)
# Request headers
    request['Content-Type'] = 'application/json'
# Request headers
    request['Ocp-Apim-Subscription-Key'] = 'c48485623e4548bd958b7d526c535fb3'
# Request body
    request.body = "{\"name\": \"#{group_name}\"}"

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
    end

    puts response.body

  end
end
