require "test_helper"

class BmrCalculatorTest < ActiveSupport::TestCase
  test "should calculate BMR using Mifflin-San Jeor formula for male" do
    result = BmrCalculator.calculate!(
      formula: "mifflin_san_jeor",
      sex: "male",
      weight_kg: 70,
      height_cm: 180,
      age_years: 30
    )
    expected = (10 * 70) + (6.25 * 180) - (5 * 30) + 5
    assert_equal expected.round(2), result
  end

  test "should calculate BMR using Mifflin-San Jeor formula for female" do
    result = BmrCalculator.calculate!(
      formula: "mifflin_san_jeor",
      sex: "female",
      weight_kg: 60,
      height_cm: 165,
      age_years: 25
    )
    expected = (10 * 60) + (6.25 * 165) - (5 * 25) - 161
    assert_equal expected.round(2), result
  end

  test "should calculate BMR using Harris-Benedict formula for male" do
    result = BmrCalculator.calculate!(
      formula: "harris_benedict",
      sex: "male",
      weight_kg: 70,
      height_cm: 180,
      age_years: 30
    )
    expected = 88.362 + (13.397 * 70) + (4.799 * 180) - (5.677 * 30)
    assert_equal expected.round(2), result
  end

  test "should calculate BMR using Harris-Benedict formula for female" do
    result = BmrCalculator.calculate!(
      formula: "harris_benedict",
      sex: "female",
      weight_kg: 60,
      height_cm: 165,
      age_years: 25
    )
    expected = 447.593 + (9.247 * 60) + (3.098 * 165) - (4.330 * 25)
    assert_equal expected.round(2), result
  end

  test "should raise InvalidParamsError for invalid sex" do
    assert_raises(BmrCalculator::InvalidParamsError) do
      BmrCalculator.calculate!(
        formula: "mifflin_san_jeor",
        sex: "invalid",
        weight_kg: 70,
        height_cm: 180,
        age_years: 30
      )
    end
  end

  test "should raise InvalidParamsError for non-positive values" do
    assert_raises(BmrCalculator::InvalidParamsError) do
      BmrCalculator.calculate!(
        formula: "mifflin_san_jeor",
        sex: "male",
        weight_kg: 0,
        height_cm: 180,
        age_years: 30
      )
    end
  end

  test "should raise UnsupportedFormulaError for unsupported formula" do
    assert_raises(BmrCalculator::UnsupportedFormulaError) do
      BmrCalculator.calculate!(
        formula: "invalid_formula",
        sex: "male",
        weight_kg: 70,
        height_cm: 180,
        age_years: 30
      )
    end
  end
end