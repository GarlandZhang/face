require 'net/http'
require 'json'
require 'base64'
require 'set'

class UserImagesController < ApplicationController

  def search
    @user = User.find(params[:id])
    @images_found = SearchFilter.new(entities: user.user_images, input: params[:name]).search_entities_from_input
  end

  def new
    @user = User.find(params[:id])
    @user_image = UserImage.new
  end

  def show
    @user_image = UserImage.find(params[:id])
    @people = @user_image.people
  end

  def create
    puts "==================================="
    @user = User.find(params[:id])

    #TODO: fix form input
    #urls = user_image_params[:url].split(',')
    photos = params[:user_image][:images]
    #photos.each do |photo| puts photo.read end
    # add_user_images(urls)
    add_user_images(photos)
    if @user.save
      redirect_to controller: 'pages', action: 'dashboard', id: @user.id
    else
      puts @user.errors.full_messages
    end

    puts "==================================="
  end

  private

  def user_image_params
    params.require(:user_image).permit(:url, :images)
  end

  def add_user_images(photos)
    photos.each do |photo|
      faces = detect_faces(photo.read)
      if faces != []
        puts "Faces detected: #{faces}"
        user_image = UserImage.new
        user_image.image.attach(photo)
        populate(@user.person_group, user_image, faces)
        @user.user_images << user_image
      else
        puts "No faces detected!"
      end
    end
  end
=begin

  def add_user_images(urls)
    urls.each do |url|
      faces = detect_faces(url)
      puts "Faces detected: #{faces}"
      user_image = UserImage.new({:url => url, :user_id => @user.id})
      populate(@user.person_group, user_image, faces)
      @user.user_images << user_image
    end
  end
=end

  def populate(group, user_image, faces)
    if group.people.size == 0
      puts "No people in database"
      people = add_people(group, user_image, faces)
    else
      puts "At least one person in database"
      train_person_group(group)
      people = identify_people(group, user_image, faces) # also adds person(s) if no successful candidate
    end
    if people != []
      add_people_to_image(people, user_image)
      add_faces_to_people(group, people, user_image, faces)
      build_relationships(people)
    else
      puts "No people id'd or added!"
    end
  end

  def add_people_to_image(people, user_image)
    people.each do |person|
      add_person_to_image(person, user_image)
    end
  end

  def add_faces_to_people(group, people, user_image, faces)
    people.each do |person|
      detected_face = faces.select{ |face| face['faceId'] == person.last_face_id}[0]
      puts "Detected face: #{detected_face}"
      add_face_to_person(group, person, user_image.image.download, detected_face)
    end
  end

  def build_relationships(people)
    puts "people: #{people} with size: #{people.size}"
    people.each do |main|
      people.each do |friend|
        puts "main: #{main.name}(#id: #{main.id}) and friend: #{friend.name}(#id: #{friend.id})"
        if main.id != friend.id && !in_relationship(main,friend)
          puts "Building relatiionship between #{main.id}(#{main.name}) and #{friend.id}(#{friend.name})"
          build_relationship(main, friend)
        end
      end
    end
    people
  end

  def in_relationship(main, friend)
    (main.relationships.select do |relationship|
      puts "relationship info | person_id: #{relationship.person_id}, friend_id: #{relationship.friend_id}"
      relationship.friend_id == friend.id
    end).size != 0
  end

  def build_relationship(main, friend)
    main.relationships << Relationship.new(:friend_id => friend.id)
    friend.relationships << Relationship.new(:friend_id => main.id)
  end

  # todo: extract add_face_to_person from method (modularize)
  def add_people(group, user_image, faces)
    people = []
    #todo: what if person appears more than once in image?
    faces.each do |face|
      person = add_person(group, user_image.image, face)
      puts "Person created: #{person.name} with personId: #{person.person_id}"
      people << person
    end
    puts "people added: #{people}"
    people
  end

  def add_person_to_image(person, user_image)
    user_image.people << person
  end

  def post_call_azure(end_point, request_params={}, request_body = "{}", request_type='json')
    uri = URI("https://westcentralus.api.cognitive.microsoft.com/face/v1.0/#{end_point}")
    uri.query = URI.encode_www_form(request_params)
    request = Net::HTTP::Post.new(uri.request_uri)
    # Request headers
    request['Content-Type'] = "application/#{request_type}"
    # Request headers
    request['Ocp-Apim-Subscription-Key'] = 'c48485623e4548bd958b7d526c535fb3'
    # Request body
    request.body = request_body
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
    end


    body = response.body != ""? JSON.parse(response.body) : ""

    puts "Code: #{response.code}"
    #todo: worry about other errors (actually they send a code back so thats more reliable than this)
    if response.code == "429"
      sleep(10)
      body = post_call_azure(end_point, request_params, request_body, request_type)
    end

    body
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

    body = response.body != ""? JSON.parse(response.body) : ""
    puts "Code: #{response.code}"
    #todo: worry about other errors (actually they send a code back so thats more reliable than this)
    if response.code == "429"
      sleep(10)
      body = get_call_azure(end_point, request_params, request_body)
    end

    body
  end

  def detect_faces(binary_photo)
    post_call_azure("detect", {
        # Request parameters
        'returnFaceId' => 'true',
        'returnFaceLandmarks' => 'false',
    }, binary_photo, "octet-stream")
  end
=begin

  def detect_faces(url)
    JSON.parse(post_call_azure("detect", {
        # Request parameters
        'returnFaceId' => 'true',
        'returnFaceLandmarks' => 'false',
    }, "{\"url\": \"#{url}\"}"))
  end
=end

  def train_person_group(group)
    post_call_azure("persongroups/#{group.azure_id}/train")

    # todo: use scheduling tasks
    loop do
      response = get_training_status(group)
      puts response
      sleep 1
      break if response['status'] != "running"
    end

  end

  def get_training_status(group)
    get_call_azure("persongroups/#{group.azure_id}/training")
  end

  def identify_people(group, user_image, faces)
    face_ids = faces.collect { |face| face['faceId']}

    identified_faces = get_identities(group, face_ids)
    people = []
    identified_faces.each do |id_face|
      puts "ID_face currently: #{id_face}"
      if id_face['candidates'].size == 0
        puts "Candidate size is 0"
        detected_face = faces.select{ |face| face['faceId'] == id_face['faceId']}[0]
        person = add_person(group, user_image.image, detected_face)
      else
        # TODO: use by person id not name cause name can change
        puts "Candidate size is at least 1"
        person = Person.find_by_person_id(id_face['candidates'][0]['personId'])
        person.last_face_id = id_face['faceId']
      end
      puts "person added/found: #{person.name}"
      people << person
      puts "people id'd and added: #{people}"
    end
    people
  end

  def get_identities(group, face_ids)
    response = post_call_azure("identify", {},  "{
      \"personGroupId\": \"#{group.azure_id}\",
      \"faceIds\": #{face_ids}}")
    puts "Response from identifies: #{response}"
    response
  end

  def add_person(group, photo, face)
    puts "Adding person with face: #{face}"
    azure_added_person = add_azure_person(group, face['faceId'])
    azure_person = get_azure_person(group, azure_added_person['personId'])
    puts "photo: #{photo}"
    #crop_profile_pic(photo, face['faceRectangle'])
    person = Person.new({:name => azure_person['name'], :last_face_id => azure_person['name'], :person_id => azure_person['personId']})
    face_rectangle = face['faceRectangle']
    person.face_width = face_rectangle['width']
    person.face_height = face_rectangle['height']
    person.face_offset_x = face_rectangle['left']
    person.face_offset_y = face_rectangle['top']
    person.avatar.attach(photo.blob)
    group.people << person
    person
  end

  def crop_profile_pic(photo, face_rectangle)
    puts "Face rectangle: #{face_rectangle}"
    profile_pic = MiniMagick::Image.new(url_for(photo))
    puts "gotten"
    profile_pic.colorspace "Gray"
    #profile_pic.crop "#{face_rectangle['width']}x#{face_rectangle['height']}+#{face_rectangle['left']}+#{face_rectangle['top']}"
  end

  def add_face_to_person(group, person, binary_photo, detected_face)
    puts "Adding face: #{detected_face} to person: #{person.name}"
    face_rectangle = detected_face['faceRectangle']
    left = face_rectangle['left']
    top = face_rectangle['top']
    width = face_rectangle['width']
    height = face_rectangle['height']

    response = post_call_azure("persongroups/#{group.azure_id}/persons/#{person.person_id}/persistedFaces",
               { 'targetFace' => "#{left},#{top},#{width},#{height}"},
               binary_photo,
                               "octet-stream")
    puts "Added face to person: #{response}"
    response
  end

  def add_azure_person(group, face_id)
    response = post_call_azure("persongroups/#{group.azure_id}/persons", {}, "{\"name\": \"#{face_id}\"}")
    puts "Added azure person: #{response}"
    response
  end

  def get_azure_person(group, person_id)
    response = get_call_azure("persongroups/#{group.azure_id}/persons/#{person_id}", {})
    puts "Get azure person: #{response}"
    response
  end

  def attr_reader :user
end
