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
      puts "Faces detected: #{faces}"
      user_image = UserImage.new({:url => url, :user_id => @user.id})
      populate(@user.person_group, user_image, faces)
      @user.user_images << user_image
    end
  end

  def populate(group, user_image, faces)
    if group.people.size == 0
      puts "No people in database"
      generate_people_and_add_faces(group, user_image, faces)
    else
      puts "At least one person in database"
      train_person_group(group)
      person = identify_person(group, faces, user_image.url)
      add_person_to_image(person, user_image)
    end
  end

  def generate_people_and_add_faces(group, user_image, faces)
    face_ids = faces.collect { |face| face['faceId']}

    #todo: what if person appears more than once in image?
    face_ids.each do |face_id|
      person = add_person(group, face_id)
      add_person_to_image(person, user_image)

      puts "Person created: #{person.name} with personId: #{person.person_id}"
      detected_face = faces.select{ |face| face['faceId'] == person.name}[0]
      add_face_to_person(group, person, user_image.url, detected_face)
    end
  end

  def add_person_to_image(person, user_image)
    user_image.people << person
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
      sleep 1
      break if response['status'] != "running"
    end

  end

  def get_training_status(group)
    get_call_azure("persongroups/#{group.azure_id}/training")
  end

  def identify_person(group, faces, url)
    face_ids = faces.collect { |face| face['faceId']}

    identified_faces = get_identities(group, face_ids)
    person = nil
    identified_faces.each do |id_face|
      puts "ID_face currently: #{id_face}"
      if id_face['candidates'].size == 0
        puts "Candidate size is 0"
        person = add_person(group, id_face['faceId'])
      else
        # TODO: use by person id not name cause name can change
        puts "Candidate size is at least 1"
        person = Person.find_by_person_id(id_face['candidates'][0]['personId'])
      end
      detected_face = faces.select{ |detected_face| detected_face['faceId'] == id_face['faceId']}[0]
      puts "Detected face with faceId: #{detected_face['faceId']}"
      add_face_to_person(group, person, url, detected_face)
    end
    person
  end

  def get_identities(group, face_ids)
    response = JSON.parse(post_call_azure("identify", {},  "{
      \"personGroupId\": \"#{group.azure_id}\",
      \"faceIds\": #{face_ids}}"))
    puts "Response from identifies: #{response}"
    response
  end

  def add_person(group, face_id)
    puts "Adding person with detected faceId: #{face_id}"
    azure_added_person = add_azure_person(group, face_id)
    azure_person = get_azure_person(group, azure_added_person['personId'])
    person = Person.new({:name => azure_person['name'], :person_id => azure_person['personId']})
    group.people << person
    person
  end

  def add_face_to_person(group, person, url, detected_face)
    puts "Adding face: #{detected_face} to person: #{person.name} with url: #{url}"
    face_rectangle = detected_face['faceRectangle']
    left = face_rectangle['left']
    top = face_rectangle['top']
    width = face_rectangle['width']
    height = face_rectangle['height']

    response = post_call_azure("persongroups/#{group.azure_id}/persons/#{person.person_id}/persistedFaces",
               { 'targetFace' => "#{left},#{top},#{width},#{height}"},
               "{\"url\": \"#{url}\"}")
    puts "Added face to person: #{response}"
    response
  end

  def add_azure_person(group, face_id)
    response = JSON.parse(post_call_azure("persongroups/#{group.azure_id}/persons", {}, "{\"name\": \"#{face_id}\"}"))
    puts "Added azure person: #{response}"
    response
  end

  def get_azure_person(group, person_id)
    response = JSON.parse(get_call_azure("persongroups/#{group.azure_id}/persons/#{person_id}", {}))
    puts "Get azure person: #{response}"
    response
  end
end
