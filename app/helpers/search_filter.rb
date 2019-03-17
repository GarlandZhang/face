class SearchFilter
  
  STRIP_WHITESPACE = %r(,\s*)

  def initialize(entities:, input:)
    @entities = normalize_entities(entities)
    @input = normalize_input(input)
  end
  
  def search_entities_from_input
    return [] if entities.empty?    
    entities.select { |entity| (input - entities.names).empty? } if entities[0].is_a?(:UserImage)
  end

  private

  def normalize_entities(entities)
    return [] if entities.nil?
  end

  def normalize_input(input)
    return [] if input.nil? || input.blank?
    input.split(STRIP_WHITESPACE).map { |elem| elem.try(:downcase) }
  end

  attr_reader :entities, :input

end