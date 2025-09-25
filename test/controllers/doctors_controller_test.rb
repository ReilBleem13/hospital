require "test_helper"

class DoctorsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @doctor = doctors(:one)
    @valid_attributes = {
      first_name: "Доктор",
      last_name: "Тестов",
      middle_name: "Тестович"
    }
  end

  test "should get index" do
    get doctors_url
    assert_response :success
    assert_includes response.body, "data"
    assert_includes response.body, "meta"
  end

  test "should get index with pagination" do
    get doctors_url, params: { limit: 5, offset: 0 }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 5, json_response["meta"]["limit"]
    assert_equal 0, json_response["meta"]["offset"]
  end

  test "should show doctor" do
    get doctor_url(@doctor)
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal @doctor.id, json_response["data"]["id"]
  end

  test "should return 404 for non-existent doctor" do
    get doctor_url(99999)
    assert_response :not_found
    
    json_response = JSON.parse(response.body)
    assert_includes json_response["error"], "Doctor not found"
  end

  test "should create doctor" do
    assert_difference("Doctor.count") do
      post doctors_url, params: { doctor: @valid_attributes }
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "Doctor successfully created", json_response["message"]
  end

  test "should not create doctor with invalid attributes" do
    assert_no_difference("Doctor.count") do
      post doctors_url, params: { doctor: { first_name: nil } }
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response["errors"].present?
  end

  test "should update doctor" do
    patch doctor_url(@doctor), params: { doctor: { first_name: "Обновленный доктор" } }
    assert_response :ok

    @doctor.reload
    assert_equal "Обновленный доктор", @doctor.first_name
    
    json_response = JSON.parse(response.body)
    assert_equal "Doctor successfully updated", json_response["message"]
  end

  test "should not update doctor with invalid attributes" do
    patch doctor_url(@doctor), params: { doctor: { first_name: nil } }
    assert_response :unprocessable_entity
  end

  test "should destroy doctor" do
    assert_difference("Doctor.count", -1) do
      delete doctor_url(@doctor)
    end

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Doctor successfully deleted", json_response["message"]
  end
end