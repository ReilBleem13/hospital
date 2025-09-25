require "test_helper"

class PatientTest < ActiveSupport::TestCase
  def setup
    @patient = patients(:one)
  end

  test "should be valid" do
    assert @patient.valid?
  end

  test "first_name should be present" do
    @patient.first_name = nil
    assert_not @patient.valid?
  end

  test "last_name should be present" do
    @patient.last_name = nil
    assert_not @patient.valid?
  end

  test "birthday should be present" do
    @patient.birthday = nil
    assert_not @patient.valid?
  end

  test "gender should be present" do
    @patient.gender = nil
    assert_not @patient.valid?
  end

  test "height should be present and positive" do
    @patient.height = nil
    assert_not @patient.valid?

    @patient.height = 0
    assert_not @patient.valid?

    @patient.height = -10
    assert_not @patient.valid?
  end

  test "weight should be present and positive" do
    @patient.weight = nil
    assert_not @patient.valid?

    @patient.weight = 0
    assert_not @patient.valid?

    @patient.weight = -10
    assert_not @patient.valid?
  end

  test "gender should be male or female" do
    @patient.gender = "invalid"
    assert_not @patient.valid?

    @patient.gender = "male"
    assert @patient.valid?

    @patient.gender = "female"
    assert @patient.valid?
  end

  test "birthday should not be in the future" do
    @patient.birthday = Date.current + 1.day
    assert_not @patient.valid?
    assert_includes @patient.errors[:birthday], "cannot be in the future"
  end

  test "age should not exceed 125 years" do
    @patient.birthday = Date.current - 130.years
    assert_not @patient.valid?
    assert_includes @patient.errors[:birthday], "age cannot exceed 125 years"
  end

  test "should calculate age correctly" do
    @patient.birthday = Date.current - 30.years
    assert_equal 30, @patient.age
  end

  test "should have many doctor_patients" do
    assert_respond_to @patient, :doctor_patients
  end

  test "should have many doctors through doctor_patients" do
    assert_respond_to @patient, :doctors
  end

  test "should have many bmr_calculations" do
    assert_respond_to @patient, :bmr_calculations
  end

  test "full_name_like scope should find patients by name" do
    result = Patient.full_name_like("Иван")
    assert_includes result, patients(:one)
    assert_not_includes result, patients(:two)
  end

  test "by_gender scope should filter by gender" do
    male_patients = Patient.by_gender("male")
    assert_includes male_patients, patients(:one)
    assert_not_includes male_patients, patients(:two)
  end

  test "age_between scope should filter by age range" do
    young_patients = Patient.age_between(20, 35)
    assert_includes young_patients, patients(:one)
    assert_includes young_patients, patients(:two)
  end

  test "height_between scope should filter by height range" do
    tall_patients = Patient.height_between(170, 190)
    assert_includes tall_patients, patients(:one)
    assert_not_includes tall_patients, patients(:two)
  end

  test "weight_between scope should filter by weight range" do
    heavy_patients = Patient.weight_between(70, 80)
    assert_includes heavy_patients, patients(:one)
    assert_not_includes heavy_patients, patients(:two)
  end
end
