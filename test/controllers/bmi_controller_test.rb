require "test_helper"

class BmiControllerTest < ActionDispatch::IntegrationTest
  test "should get index with valid parameters" do
    # Мокаем BmiClient
    original_new = BmiClient.method(:new)
    mock_client = Object.new
    def mock_client.fetch_bmi(weight, height)
      { bmi: 23.44, category: "Normal weight" }
    end
    
    BmiClient.define_singleton_method(:new) { |*args| mock_client }
    
    get bmi_url, params: { weight: 70, height: 180 }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 23.44, json_response["bmi"]
    assert_equal "Normal weight", json_response["category"]
    
    # Восстанавливаем оригинальный метод
    BmiClient.define_singleton_method(:new, original_new)
  end

  test "should return 400 for missing weight" do
    get bmi_url, params: { height: 180 }
    assert_response :bad_request
    
    json_response = JSON.parse(response.body)
    assert_includes json_response["error"], "Both weight and height are required"
  end

  test "should return 400 for missing height" do
    get bmi_url, params: { weight: 70 }
    assert_response :bad_request
    
    json_response = JSON.parse(response.body)
    assert_includes json_response["error"], "Both weight and height are required"
  end

  test "should return 422 for invalid parameters" do
    original_new = BmiClient.method(:new)
    mock_client = Object.new
    def mock_client.fetch_bmi(weight, height)
      raise ArgumentError, "Invalid parameters"
    end
    
    BmiClient.define_singleton_method(:new) { |*args| mock_client }
    
    get bmi_url, params: { weight: -1, height: 180 }
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["error"], "Invalid parameters"
    
    # Восстанавливаем оригинальный метод
    BmiClient.define_singleton_method(:new, original_new)
  end

  test "should return 502 for API error" do
    original_new = BmiClient.method(:new)
    mock_client = Object.new
    def mock_client.fetch_bmi(weight, height)
      raise StandardError, "API Error"
    end
    
    BmiClient.define_singleton_method(:new) { |*args| mock_client }
    
    get bmi_url, params: { weight: 70, height: 180 }
    
    assert_response :bad_gateway
    json_response = JSON.parse(response.body)
    assert_includes json_response["error"], "API Error"
    
    # Восстанавливаем оригинальный метод
    BmiClient.define_singleton_method(:new, original_new)
  end
end