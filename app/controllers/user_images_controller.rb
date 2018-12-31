require 'net/http'
require 'json'

class UserImagesController < ApplicationController
  def new
    @user = User.find(params[:id])
    @user_image = UserImage.new
  end

  def create
    puts "==================================="
    @user = User.find(params[:id])

    #TODO: fix form input
    urls = user_image_params[:url].split(',')

    add_user_images(urls)

    if @user.save
      redirect_to controller: 'pages', action: 'dashboard', id: @user.id
    else
      puts "ERROR"
    end

    puts "==================================="
  end

  private
  def user_image_params
    params.require(:user_image).permit(:url)
  end

  def add_user_images(urls)
    urls.each do |url|
      faces = detect_faces(url)
      group = @user.person_group

      if group.people.size == 0
        faceIds = []
        faces.each do |face|
          faceIds << face['faceId']
        end

        #todo: what if person appears more than once in image?
        faceIds.each do |faceId|
          person = add_person(group, faceId)
          detected_face = faces.select{ |detected_face| detected_face['faceId'] == person.name}
          add_face_to_person(group, person, url, detected_face)
        end

        if group.save
          # do something
        end
      else
        train_person_group(group)
        identify_person(group, faces, url)
      end
      @user.user_images.new({:url => url})
    end
  end

  def post_call_azure(end_point, request_params={}, request_body = "{}")
    uri = URI("https://westcentralus.api.cognitive.microsoft.com/face/v1.0/#{end_point}")
    uri.query = URI.encode_www_form(request_params)
    request = Net::HTTP::Post.new(uri.request_uri)
    # Request headers
    request['Content-Type'] = 'application/json'
    # Request headers
    request['Ocp-Apim-Subscription-Key'] = 'c48485623e4548bd958b7d526c535fb3'
    # Request body
    request.body = request_body
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
    end

    response.body
  end

  def get_call_azure(end_point, request_params={}, request_body="{}")
    uri = URI("https://westcentralus.api.cognitive.microsoft.com/face/v1.0/#{end_point}")
    uri.query = URI.encode_www_form(request_params)
    request = Net::HTTP::Get.new(uri.request_uri)
    # Request headers
    request['Content-Type'] = 'application/json'
    # Request headers
    request['Ocp-Apim-Subscription-Key'] = 'c48485623e4548bd958b7d526c535fb3'
    # Request body
    request.body = request_body
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
    end

    response.body
  end

  def detect_faces(user_image)
    JSON.parse(post_call_azure("detect", {
        # Request parameters
        'returnFaceId' => 'true',
        'returnFaceLandmarks' => 'false',
    }, "{\"url\": \"#{user_image}\"}"))
  end

  def train_person_group(group)
    post_call_azure("persongroups/#{group.azure_id}/train")

    # todo: use scheduling tasks
    loop do
      response = JSON.parse(get_training_status(group))
      puts response
      sleep 5
      break if response['status'] != "running"
    end

  end

  def get_training_status(group)
    get_call_azure("persongroups/#{group.azure_id}/training")
  end

  def identify_person(group, faces, url)
    faceIds = []
    faces.each do |face|
      faceIds << face['faceId']
    end

    response = ""

    if group.people.size != 0

      identified_faces = JSON.parse(post_call_azure("identify", {},  "{
      \"personGroupId\": \"#{group.azure_id}\",
      \"faceIds\": #{faceIds}}"))

      person = nil
      identified_faces.each do |face|
        if face['candidates'].size == 0
          person = add_person(group, face['faceId'])
        else
          # TODO: use by person id not name cause name can change
          person = Person.find_by_name(face['candidates'][0]['personId'])
        end
        detected_face = faces.select{ |detected_face| detected_face['faceId'] == face['faceId']}[0]
        add_face_to_person(group, person, url, detected_face)
      end
    end

    if group.save
      # do something
    end

    response
  end

  def add_person(group, faceId)
    azure_person = JSON.parse(post_call_azure("persongroups/#{group.azure_id}/persons", {}, "{\"name\": \"#{faceId}\"}"))
    person = Person.new({:name => azure_person['personId']})
    group.people << person
    if group.save
      # do something
    end
    person
  end

  def add_face_to_person(group, person, url, detected_face)
    face_rectangle = detected_face['faceRectangle']
    left = face_rectangle['left']
    top = face_rectangle['top']
    width = face_rectangle['width']
    height = face_rectangle['height']

    puts post_call_azure("persongroups/#{group.azure_id}/persons/#{person.name}/persistedFaces",
               { 'targetFace' => "#{left},#{top},#{width},#{height}"},
               "{\"url\": \"#{url}\"}")
  end
end
