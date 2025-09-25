require "net/http"
require "uri"

class HttpAdapter
  Response = Struct.new(:status, :body)

  def get(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    Response.new(response.code.to_i, response.body)
  end
end
