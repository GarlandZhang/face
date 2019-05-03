require 'net/http'

class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.person_group ||= create_person_group
    if @user.save
      redirect_to controller: 'pages', action: 'dashboard', id: @user.id
    end
  end

  private

  attr_reader :user

  def user_params
    params.required(:user).permit(:username)
  end

  def create_person_group
    username = user.username
    group_id = "person_group_#{username}"
    group_name = "#{username}_image_collection"

    FaceApi.create_cloud_person_group(group_id, group_name)
    PersonGroup.new({:azure_id => group_id, :name => group_name})
  end
end
