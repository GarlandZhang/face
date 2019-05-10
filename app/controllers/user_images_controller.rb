class UserImagesController < ApplicationController

  def search
    @user = User.find(params[:id])
    @images_found = SearchFilter.new(entities: user.user_images, input: params[:names]).search_entities_from_input
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
    normalize_photos.each do |photo|
      data = extract_data_from_photo(photo)
      people = data['people']
      user.person_group.add_new_people(people)
      user.user_images << UserImage.new(people: people, image: photo)
    end
    if user.save
      redirect_to controller: 'pages', action: 'dashboard', id: user.id
    else
      puts user.errors.full_messages
    end

    puts "==================================="
  end

  private

  def normalize_photos
    params[:user_image].try(:[], :images) || []
  end

  def user_image_params
    params.require(:user_image).permit(:url, :images)
  end

  def extract_data_from_photo(photo)
    image_data = photo.read
    {
      "tags" => extract_tags_from_photo(image_data),
      "people" => extract_people_from_photo(photo: photo, image_data: image_data)
    }
  end

  def extract_tags_from_photo(image_data)
    tags = ObjectDetectApi.image_tags(image_data)
    if tags.is_a?(Hash)
      tags['description']['tags']
    end
  end

  def extract_people_from_photo(photo:, image_data:)
    image_data = photo.read
    get_people(
      person_group: FaceApi.train_person_group(user.person_group), 
      faces: FaceApi.detect_faces(image_data),
      photo: photo,
      image_data: image_data,
    )
  end

  def get_people(person_group:, faces:, photo:, image_data:)
    new_ids = faces.map { |face| face['faceId'] }
    existing_ids = FaceApi.person_identities(person_group: person_group, face_ids: new_ids)
    people = []
    existing_ids.each do |existing_id|
      if (person = existing_person(existing_id))
        people << person
        new_ids.delete(existing_id['faceId'])
      end
    end
    new_ids.each do |new_id|
      people << new_person(person_group: person_group, face: detected_face(faces: faces, target: new_id), photo: photo, image_data: image_data)
    end
    people
  end

  def existing_person(id)
    candidates = id['candidates']
    return if candidates.empty?
    candidate = candidates.first['personId']
    person = Person.find_by_person_id(candidate)
    person.last_face_id = id['faceId']
    person
  end

  def new_person(person_group:, face:, photo:, image_data:)
    person = to_person_from_cloud(person_group: person_group, face: face, image_data: image_data)
    face_rectangle = face['faceRectangle']
    person.face_width = face_rectangle['width']
    person.face_height = face_rectangle['height']
    person.face_offset_x = face_rectangle['left']
    person.face_offset_y = face_rectangle['top']
    person.last_face_id = face['faceId']
    person.avatar.attach(photo)
    person
  end

  def detected_face(faces:, target:)
    faces.select{ |face| face['faceId'] == target }[0]
  end
  
  def to_person_from_cloud(person_group:, face:, image_data:)
    person_in_cloud = FaceApi.create_cloud_person(person_group: person_group, face_id: face['faceId'])
    face_rectangle = face['faceRectangle']
    person = Person.new(
      name: person_in_cloud['name'], 
      last_face_id: person_in_cloud['name'], 
      person_id: person_in_cloud['personId'],
      face_width: face_rectangle['width'],
      face_height: face_rectangle['height'],
      face_offset_x: face_rectangle['left'],
      face_offset_y: face_rectangle['top'],
    )
    FaceApi.add_face_to_person(person_group: person_group, person_id: person.person_id, face_rectangle: face_rectangle, image_data: image_data)
    person
  end

  attr_reader :user
end
