module ImageStore
  URL = 'https://api.imgur.com/3/'
  CLIENT_ID = '546c25a59c58ad7'
  CLIENT_SECRET = 'c750216cb24c8f95fbf3a12436f3f6a05d88dadd'

  class << self
    def upload_image(image)
      uri = uri_setup(endpoint_name: 'upload')
      request_body = image
      request = request_setup(request_uri: uri.request_uri, request_type: 'application/octet-stream', request_body: request_body, http_method: Net::HTTP::Post)
      get_response(uri: uri, request: request)['data']['link']
    end
    alias_method :image_url, :upload_image

    private

    def get_response(uri:, request:)
      response = Net::HTTP.start(
        uri.host, 
        uri.port, 
        :use_ssl => uri.scheme == 'https',
      ) { |http| http.request(request) }
      response_body = response.body
      response_body.blank? ? "" : JSON.parse(response_body)
    end

    def uri_setup(endpoint_name:, request_params: {})
      uri = URI(URL + endpoint_name)
      uri.query = URI.encode_www_form(request_params)
      uri
    end

    def request_setup(request_uri:, request_type:, request_body:, http_method:)
      request = http_method.new(request_uri)
      request['Authorization'] = "Client-ID #{CLIENT_ID}"
      request['Content-Type'] = "#{request_type}"
      request.body = request_body.to_s
      request
    end
  end
end