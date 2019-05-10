module ApiSetup
  URL = "https://westcentralus.api.cognitive.microsoft.com/"

  RESPONSE_CODES = { 
    200 => :success,
    202 => :success,
    429 => :rate_limit_exceeded,
    401 => :unspecified,
    400 => :bad_request,
  }

  REQUEST_TYPE_JSON = 'json'
  REQUEST_TYPE_OS = 'octet-stream'

  class << self
    def put_call_azure(endpoint_name:, request_params: {}, request_body: {}, request_type: REQUEST_TYPE_JSON, subscription_key:)
      call_azure(
        endpoint_name: endpoint_name, 
        request_params: request_params, 
        request_body: request_body, 
        request_type: request_type, 
        subscription_key: subscription_key, 
        http_method: Net::HTTP::Put,
      )
    end

    def get_call_azure(endpoint_name:, request_params: {}, request_body: {}, request_type: REQUEST_TYPE_JSON, subscription_key:)
      call_azure(
        endpoint_name: endpoint_name, 
        request_params: request_params, 
        request_body: request_body, 
        request_type: request_type, 
        subscription_key: subscription_key, 
        http_method: Net::HTTP::Get,
      )
    end

    def post_call_azure(endpoint_name:, request_params: {}, request_body: {}, request_type: REQUEST_TYPE_JSON, subscription_key:)
      call_azure(
        endpoint_name: endpoint_name, 
        request_params: request_params, 
        request_body: request_body, 
        request_type: request_type, 
        subscription_key: subscription_key, 
        http_method: Net::HTTP::Post,
      )
    end

    private

    def call_azure(endpoint_name:, request_params:, request_body:, request_type:, subscription_key:, http_method:)
      uri = uri_setup(endpoint_name: endpoint_name, request_params: request_params)
      request = request_setup(request_uri: uri.request_uri, request_type: request_type, request_body: request_body, subscription_key: subscription_key, http_method: http_method)
      get_response(uri: uri, request: request)
    end

    def get_response(uri:, request:)
      normalize_response(spam_call(uri: uri, request: request))
    end

    def normalize_response(response_body)
      response_body.blank? ? "" : JSON.parse(response_body)
    end

    def spam_call(uri:, request:, code: :rate_limit_exceeded)
      response = get_call_response(uri: uri, request: request)  
      while RESPONSE_CODES[response.code.to_i] == code
        sleep(10)
        response = get_call_response(uri: uri, request: request)  
        puts "Retrying..."
      end
      
      if RESPONSE_CODES[response.code.to_i] == :success
        response.body
      else
        puts "============================"
        puts "Error: something went wrong. Status code: #{response.code}"
        puts response.body
        puts "============================"
      end
    end

    def uri_setup(endpoint_name:, request_params:)
      uri = URI(URL + endpoint_name)
      uri.query = URI.encode_www_form(request_params)
      uri
    end

    def request_setup(request_uri:, request_type:, request_body:, subscription_key:, http_method: :get)
      request = http_method.new(request_uri)
      request['Content-Type'] = "application/#{request_type}"
      request['Ocp-Apim-Subscription-Key'] = subscription_key
      request.body = request_body.to_s
      request
    end

    def get_call_response(uri:, request:)
      Net::HTTP.start(
        uri.host, 
        uri.port, 
        :use_ssl => uri.scheme == 'https',
      ) { |http| http.request(request) }
    end
  end
end