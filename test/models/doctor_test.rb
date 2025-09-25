require "test_helper"

class DoctorTest < ActiveSupport::TestCase
  def setup
    @doctor = doctors(:one)
  end

  test "should be valid" do
    assert @doctor.valid?
  end
  
  test "first_name should be present" do
    @doctor.first_name = nil
    assert_not @doctor.valid?
  end
  
  test "last_name should be present" do
    @doctor.last_name = nil
    assert_not @doctor.valid?
  end

  test "should have many doctor_patients" do
    assert_respond_to @doctor, :doctor_patients
  end

  test "should have many patients through doctor_patients" do
    assert_respond_to @doctor, :patients
  end

  test "should validate uniqueness of first_name scoped to last_name and middle_name" do
    duplicate_doctor = Doctor.new(
      first_name: @doctor.first_name,
      last_name: @doctor.last_name,
      middle_name: @doctor.middle_name
    )
    assert_not duplicate_doctor.valid?
    assert_includes duplicate_doctor.errors[:first_name], "Doctor already exists"
  end
end
