require 'test_helper'

class SearchFilterTest < ActiveSupport::TestCase
    def setup
    end

    test "#search_entities_from_input returns empty array if input is nil" do
      search_filter = SearchFilter.new(entities: nil, input: nil)
      assert_equal [], search_filter.search_entities_from_input
    end

    test "#search_entities_from_input returns empty array if input is empty" do
      search_filter = SearchFilter.new(entities: nil, input: "")
      assert_equal [], search_filter.search_entities_from_input
    end
end