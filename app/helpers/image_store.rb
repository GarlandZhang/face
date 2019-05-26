module ImageStore

  URL = 'https://api.imgur.com/3/'
  client_id = '546c25a59c58ad7'
  client_secret = 'c750216cb24c8f95fbf3a12436f3f6a05d88dadd'


  self << class
    def upload_image(image)
      uri = uri_setup(endpoint_name: 'upload', request_params: { 'Authorization' => ('Client-ID ' + client_id) })
      request_body = { "image" => image }
      request = request_setup(request_uri: uri.request_uri, request_type: 'multipart/form-data', request_body: request_body, http_method: Net::HTTP::Post)
      get_response(uri: uri, request: request)
    end

    private

    def get_response(uri:, request:)
      response_body = Net::HTTP.start(
        uri.host, 
        uri.port, 
        :use_ssl => uri.scheme == 'https',
      ) { |http| http.request(request) }
      
      response_body.blank? ? "" : JSON.parse(response_body)
    end

    def uri_setup(endpoint_name:, request_params:)
      uri = URI(URL + endpoint_name)
      uri.query = URI.encode_www_form(request_params)
      uri
    end

    def request_setup(request_uri:, request_type:, request_body:, http_method:)
      request = http_method.new(request_uri)
      request['Content-Type'] = "application/#{request_type}"
      request.body = request_body.to_s
      request
    end
    
  end
end