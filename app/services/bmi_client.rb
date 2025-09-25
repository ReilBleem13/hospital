class BmiClient
  API_BASE_URL = "https://bmicalculatorapi.vercel.app".freeze

  def initialize(http_adapter: HttpAdapter.new)
    @http = http_adapter
  end

  def fetch_bmi(weight_kg, height_cm)
    weight = Float(weight_kg)
    height_cm = Float(height_cm) / 100.0

    raise ArgumentError, "height must be greater than 0" if height_cm <= 0.0
    raise ArgumentError, "weight must be greater than 0" if weight <= 0.0

    url = "#{API_BASE_URL}/api/bmi/#{weight}/#{height_cm}"
    response = @http.get(url)

    unless response.status == 200
      raise StandardError, "BMI API returned status #{response.status}"
    end

    parse_json(response.body)
  end

  private

  def parse_json(body)
    json = JSON.parse(body)
    symbolize_keys(json)
  rescue JSON::ParserError => e
    raise StandardError, "Failed to parse BMI API response: #{e.message}"
  end

  def symbolize_keys(obj)
    case obj
    when Array
      obj.map { |v| symbolize_keys(v) }
    when Hash
      obj.transform_keys { |k| k.to_s.downcase.to_sym }.transform_values { |v| symbolize_keys(v) }
    else
      obj
    end
  end
end

