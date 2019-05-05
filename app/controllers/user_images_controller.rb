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
    photos = normalize_photos(params[:user_image][:images])
    photos.each do |photo|
      people = extract_people_from_photo(photo)
      user.person_group.add_new_people(people)
      user.user_images << UserImage.new(people: people, image: photo)
    end
    if user.save
      redirect_to controller: 'pages', action: 'dashboard', id: @user.id
    else
      puts user.errors.full_messages
    end

    puts "==================================="
  end

  private

  def normalize_photos(photos)
    return [] if photos.nil? || photos.empty?
    photos
  end

  def user_image_params
    params.require(:user_image).permit(:url, :images)
  end

  def normalize_people(people)
    for main in 0..people.size - 1
      for friend in (main + 1)..people.size - 1
        people[main].build_relationship(people[friend]) if main != friend
      end
    end
    people
  end

  def extract_people_from_photo(photo)
    normalize_people(get_people(
      person_group: FaceApi.train_person_group(user.person_group), 
      faces: FaceApi.detect_faces(photo.read),
      photo: photo,
    ))
  end

  def get_people(person_group:, faces:, photo:)
    face_ids = faces.map { |face| face['faceId'] }
    puts "face_ids: #{face_ids}"
    existing_ids = FaceApi.person_identities(person_group: person_group, face_ids: face_ids)
    existing_people = existing_ids.each_with_object([]) do |existing_id, people|
      face_ids.delete(existing_id)
      people << Person.find_by_person_id(existing_id)
    end
    new_people = face_ids.each_with_object([]) do |new_id, people|
      people << new_person(person_group: person_group, face: detected_face(faces: faces, target: new_id), photo: photo)
    end
    puts "existing_people: #{existing_people} | #{new_people}"
    existing_people.concat(new_people)
  end

  def new_person(person_group:, face:, photo:)
    person = to_person_from_cloud(person_group: person_group, face_id: face['faceId'])
    face_rectangle = face['faceRectangle']
    person.face_width = face_rectangle['width']
    person.face_height = face_rectangle['height']
    person.face_offset_x = face_rectangle['left']
    person.face_offset_y = face_rectangle['top']
    person.last_face_id = face['faceId']
    # person.avatar.attach(photo)
    person
  end

  def detected_face(faces:, target:)
    puts "detected_face: #{faces.select{ |face| face['faceId'] == target }[0]}"
    faces.select{ |face| face['faceId'] == target }[0]
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
    request['Ocp-Apim-Subscription-Key'] = '34b4563891a147239c593cb83f6eca63'
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
    request['Ocp-Apim-Subscription-Key'] = '34b4563891a147239c593cb83f6eca63'
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

  def to_person_from_cloud(person_group:, face_id:)
    person_in_cloud = FaceApi.create_cloud_person(person_group: person_group, face_id: face_id)
    Person.new(
      name: person_in_cloud['name'], 
      last_face_id: person_in_cloud['name'], 
      person_id: person_in_cloud['personId']
    )
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

  attr_reader :user
end
