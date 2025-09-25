require "test_helper"

class BmrCalculationTest < ActiveSupport::TestCase
  def setup
    @bmr_calculation = bmr_calculations(:one)
  end

  test "should be valid" do
    assert @bmr_calculation.valid?
  end

  test "formula should be present" do
    @bmr_calculation.formula = nil
    assert_not @bmr_calculation.valid?
  end

  test "value should be present" do
    @bmr_calculation.value = nil
    assert_not @bmr_calculation.valid?
  end

  test "computed_at should be present" do
    @bmr_calculation.computed_at = nil
    assert_not @bmr_calculation.valid?
  end

  test "formula should be mifflin_san_jeor or harris_benedict" do
    @bmr_calculation.formula = "invalid_formula"
    assert_not @bmr_calculation.valid?

    @bmr_calculation.formula = "mifflin_san_jeor"
    assert @bmr_calculation.valid?

    @bmr_calculation.formula = "harris_benedict"
    assert @bmr_calculation.valid?
  end

  test "value should be positive" do
    @bmr_calculation.value = 0
    assert_not @bmr_calculation.valid?

    @bmr_calculation.value = -100
    assert_not @bmr_calculation.valid?
  end

  test "should belong to patient" do
    assert_respond_to @bmr_calculation, :patient
    assert_equal patients(:one), @bmr_calculation.patient
  end
end
