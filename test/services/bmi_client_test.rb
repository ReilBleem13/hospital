require "test_helper"

class BmiClientTest < ActiveSupport::TestCase
  test "should fetch BMI successfully" do
    mock_response = Object.new
    def mock_response.status; 200; end
    def mock_response.body; '{"bmi": 23.44, "category": "Normal weight"}'; end
    
    mock_adapter = Object.new
    def mock_adapter.get(url)
      mock_response = Object.new
      def mock_response.status; 200; end
      def mock_response.body; '{"bmi": 23.44, "category": "Normal weight"}'; end
      mock_response
    end
    
    bmi_client = BmiClient.new(http_adapter: mock_adapter)
    result = bmi_client.fetch_bmi(70, 180)
    
    assert_equal 23.44, result[:bmi]
    assert_equal "Normal weight", result[:category]
  end

  test "should raise ArgumentError for zero height" do
    bmi_client = BmiClient.new
    assert_raises(ArgumentError, "height must be greater than 0") do
      bmi_client.fetch_bmi(70, 0)
    end
  end

  test "should raise ArgumentError for zero weight" do
    bmi_client = BmiClient.new
    assert_raises(ArgumentError, "weight must be greater than 0") do
      bmi_client.fetch_bmi(0, 180)
    end
  end

  test "should raise StandardError for non-200 status" do
    mock_response = Object.new
    def mock_response.status; 500; end
    def mock_response.body; 'Internal Server Error'; end
    
    mock_adapter = Object.new
    def mock_adapter.get(url)
      mock_response = Object.new
      def mock_response.status; 500; end
      def mock_response.body; 'Internal Server Error'; end
      mock_response
    end
    
    bmi_client = BmiClient.new(http_adapter: mock_adapter)
    
    assert_raises(StandardError, "BMI API returned status 500") do
      bmi_client.fetch_bmi(70, 180)
    end
  end

  test "should raise StandardError for invalid JSON" do
    mock_adapter = Object.new
    def mock_adapter.get(url)
      mock_response = Object.new
      def mock_response.status; 200; end
      def mock_response.body; 'invalid json'; end
      mock_response
    end
    
    bmi_client = BmiClient.new(http_adapter: mock_adapter)
    
    assert_raises(StandardError, /Failed to parse BMI API response/) do
      bmi_client.fetch_bmi(70, 180)
    end
  end
end