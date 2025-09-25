require "test_helper"

class PatientFilterTest < ActiveSupport::TestCase
  test "should return all patients without filters" do
    filter = PatientFilter.new({})
    result = filter.call

    assert_equal Patient.count, result[:meta][:total]
    assert_equal 10, result[:meta][:limit] 
    assert_equal 0, result[:meta][:offset] 
  end

  test "should filter by full name" do
    filter = PatientFilter.new({ full_name: "Иван" })
    result = filter.call

    assert_equal 1, result[:meta][:total]
    assert_includes result[:records], patients(:one)
    assert_not_includes result[:records], patients(:two)
  end

  test "should filter by gender" do
    filter = PatientFilter.new({ gender: "male" })
    result = filter.call

    assert_equal 1, result[:meta][:total]
    assert_includes result[:records], patients(:one)
    assert_not_includes result[:records], patients(:two)
  end

  test "should filter by age range" do
    filter = PatientFilter.new({ start_age: 20, end_age: 35 })
    result = filter.call

    assert_equal 2, result[:meta][:total]
    assert_includes result[:records], patients(:one)
    assert_includes result[:records], patients(:two)
  end

  test "should filter by height range" do
    filter = PatientFilter.new({ min_height: 170, max_height: 190 })
    result = filter.call

    assert_equal 1, result[:meta][:total]
    assert_includes result[:records], patients(:one)
    assert_not_includes result[:records], patients(:two)
  end

  test "should filter by weight range" do
    filter = PatientFilter.new({ min_weight: 70, max_weight: 80 })
    result = filter.call

    assert_equal 1, result[:meta][:total]
    assert_includes result[:records], patients(:one)
    assert_not_includes result[:records], patients(:two)
  end

  test "should respect pagination limits" do
    filter = PatientFilter.new({ limit: 1, offset: 0 })
    result = filter.call

    assert_equal 1, result[:records].count
    assert_equal 1, result[:meta][:limit]
    assert_equal 0, result[:meta][:offset]
  end

  test "should limit maximum page size to 20" do
    filter = PatientFilter.new({ limit: 100 })
    result = filter.call

    assert_equal 20, result[:meta][:limit]
  end

  test "should not allow negative offset" do
    filter = PatientFilter.new({ offset: -10 })
    result = filter.call

    assert_equal 0, result[:meta][:offset]
  end
end