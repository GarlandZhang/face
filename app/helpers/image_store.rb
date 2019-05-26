module ImageStore

  URL = 'https://api.imgur.com/3'
  client_id = '546c25a59c58ad7'
  client_secret = 'c750216cb24c8f95fbf3a12436f3f6a05d88dadd'


  self << class
    def upload_image(image)
      uri = uri_setup(endpoint_name: endpoint_name, request_params: request_params)
      request = request_setup(request_uri: uri.request_uri, request_type: request_type, request_body: request_body, subscription_key: subscription_key, http_method: http_method)
      get_response(uri: uri, request: request)
    end

    private

    def uri_setup(endpoint_name:, request_params:)
      uri = URI(URL + endpoint_name)
      uri.query = URI.encode_www_form(request_params)
      uri
    end

    
  end
end