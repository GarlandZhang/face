require 'test_helper'

class SearchFilterTest < ActiveSupport::TestCase
    def setup
      @input = ["Alex", "Andrew", "Bethany"]
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
      search_filter = SearchFilter.new(entities: nil, input: input)
      assert_equal [], search_filter.search_entities_from_input
    end
end