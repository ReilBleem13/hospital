require "test_helper"

class PatientsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @patient = patients(:one)
    @valid_attributes = {
      first_name: "Тест",
      last_name: "Тестов",
      middle_name: "Тестович",
      birthday: 30.years.ago.to_date,
      gender: "male",
      height: 180,
      weight: 75
    }
  end

  test "should get index" do
    get patients_url
    assert_response :success
    assert_includes response.body, "data"
    assert_includes response.body, "meta"
  end

  test "should get index with filters" do
    get patients_url, params: { gender: "male" }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response["meta"]["total"]
  end

  test "should show patient" do
    get patient_url(@patient)
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal @patient.id, json_response["data"]["id"]
  end

  test "should return 404 for non-existent patient" do
    get patient_url(99999)
    assert_response :not_found
    
    json_response = JSON.parse(response.body)
    assert_includes json_response["error"], "Patient not found"
  end

  test "should create patient" do
    assert_difference("Patient.count") do
      post patients_url, params: { patient: @valid_attributes }
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "Patient successfully created", json_response["message"]
  end

  test "should not create patient with invalid attributes" do
    assert_no_difference("Patient.count") do
      post patients_url, params: { patient: { first_name: nil } }
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response["errors"].present?
  end

  test "should update patient" do
    patch patient_url(@patient), params: { patient: { first_name: "Обновлено" } }
    assert_response :ok

    @patient.reload
    assert_equal "Обновлено", @patient.first_name
    
    json_response = JSON.parse(response.body)
    assert_equal "Patient successfully updated", json_response["message"]
  end

  test "should not update patient with invalid attributes" do
    patch patient_url(@patient), params: { patient: { first_name: nil } }
    assert_response :unprocessable_entity
  end

  test "should destroy patient" do
    assert_difference("Patient.count", -1) do
      delete patient_url(@patient)
    end

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Patient successfully deleted", json_response["message"]
  end

  test "should calculate BMR" do
    assert_difference("BmrCalculation.count") do
      post bmr_patient_url(@patient), params: { formula: "mifflin_san_jeor" }
    end

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal @patient.id, json_response["patient_id"]
    assert_equal "mifflin_san_jeor", json_response["formula"]
    assert json_response["value"].is_a?(Numeric)
  end

  test "should return error for invalid BMR formula" do
    post bmr_patient_url(@patient), params: { formula: "invalid" }
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert_includes json_response["error"], "Unsupported formula"
  end

  test "should get BMR history" do
    get bmr_history_patient_url(@patient)
    assert_response :ok
    
    json_response = JSON.parse(response.body)
    assert_equal @patient.id, json_response["patient_id"]
    assert json_response["data"].is_a?(Array)
    assert json_response["meta"].present?
  end

  test "should get BMI" do
    original_new = BmiClient.method(:new)
    mock_client = Object.new
    def mock_client.fetch_bmi(weight, height)
      { bmi: 23.44, category: "Normal weight" }
    end
    
    BmiClient.define_singleton_method(:new) { |*args| mock_client }
    
    get bmi_patient_url(@patient)
    
    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal 23.44, json_response["bmi"]
    
    BmiClient.define_singleton_method(:new, original_new)
  end

  test "should not create patient with non-existent doctor" do
    invalid_doctor_id = 99999
    patient_attributes = {
      first_name: "Анна",
      last_name: "Петрова",
      birthday: "1995-05-15",
      gender: "female",
      height: 165,
      weight: 60,
      doctor_ids: [invalid_doctor_id]
    }

    assert_no_difference("Patient.count") do
      post patients_url, params: { patient: patient_attributes }
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["error"], "doctor"
  end
end