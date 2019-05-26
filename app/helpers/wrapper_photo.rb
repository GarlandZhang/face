class WrapperPhoto
  attr_reader :photo

  def initialize(photo)
    @photo = photo
  end

  def image_data
    @image_data ||= photo.read
  end
end