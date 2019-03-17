require 'test_helper'

class SearchFilterTest < ActiveSupport::TestCase
    def setup
      @input = names.join(", ")
    end

    test "#search_entities_from_input returns empty array if input is empty" do
      search_filter = SearchFilter.new(entities: nil, input: "")
      assert_equal [], search_filter.search_entities_from_input
    end

    test "#search_entities_from_input returns empty array if entities is nil" do
      search_filter = SearchFilter.new(entities: nil, input: input)
      assert_equal [], search_filter.search_entities_from_input
    end

    test "#search_entities_from_input returns empty array if entities does not have common elements as input" do
      entities = [user_images(:fake)]
      search_filter = SearchFilter.new(entities: entities, input: input)
      assert_urls_of_images([], search_filter.search_entities_from_input)
    end

    test "#search_entities_from_input returns all elements that are both in entities and input" do
      input = "Andrew, Alex"
      entities = [user_images(:old_school), user_images(:fake)]
      search_filter = SearchFilter.new(entities: entities, input: input)
      assert_urls_of_images(["old_school"],  search_filter.search_entities_from_input)
    end

    test "#search_entities_from_input is not case sensitive to input nor entities" do
      input = "andrew, Alex"
      entities = [user_images(:old_school), user_images(:fake)]
      search_filter = SearchFilter.new(entities: entities, input: input)
      assert_urls_of_images(["old_school"],  search_filter.search_entities_from_input)
    end

    private

    attr_reader :input

    def people(name)
      Person.new(name: name.to_s)
    end

    def user_images(url)
      case url
      when :fake
        UserImage.new(url: url.to_s, people: [people(:fake)])
      when :old_school
        UserImage.new(url: url.to_s, people: [people(:alex), people(:andrew)])
      else
        UserImage.new(url: url.to_s, people: names.map { |name| people(name) })
      end
    end

    def names
      ["Alex", "Andrew", "Bethany", "Cynthia, Dillan, Ego"]
    end

    def assert_urls_of_images(expected, result)
      urls = result.map { |elem| elem.url }
      assert_equal expected.sort, urls.sort
    end
end