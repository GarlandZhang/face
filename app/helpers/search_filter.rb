class SearchFilter
  
  STRIP_WHITESPACE = %r(,\s*)

  def initialize(user, names)
    @user = user
    @names = normalize_names(names)
  end
  
  def search_user_images
    user.user_images.select { |image| (names - image.names).empty? }
  end

  private

  def normalize_names(names)
    return [] if names.nil? || names.blank?
    names.split(STRIP_WHITESPACE).map { |name| name.downcase }
  end

  attr_reader :user, :names

end