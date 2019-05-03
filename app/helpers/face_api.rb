module FaceApi
  URL = "https://westcentralus.api.cognitive.microsoft.com/face/v1.0/"
  SUBSCRIPTION_KEY = '74f93337be2b42b3b3611f4788878fde'

  RESPONSE_CODES = { 
    200 => :success,
    202 => :success,
    429 => :rate_limit_exceeded,
    401 => :unspecified,
    400 => :bad_request,
  }

  HTTP_METHODS = {
    :post => Net::HTTP::Post,
    :get => Net::HTTP::Get,
    :put => Net::HTTP::Put,
  }

  REQUEST_TYPE_JSON = 'json'
  REQUEST_TYPE_OS = 'octet-stream'

  class << self
    def create_cloud_person_group(group_id, group_name)
      call_azure(endpoint_name: "persongroups/#{group_id}", request_body: "{\"name\": \"#{group_name}\"}", http_method: :put)
    end

    def train_person_group(group)
      response = call_azure(endpoint_name: "persongroups/#{group.azure_id}/train", http_method: :post)
  
      # todo: use scheduling tasks
      loop do
        response = training_status(group)
        puts "training status: #{response}"
        sleep 1
        break if response['status'] != "running"
      end
      group
    end

    def training_status(group)
      call_azure(endpoint_name: "persongroups/#{group.azure_id}/training")
    end

    def create_cloud_person(person_group:, face_id:)
      cloud_person(person_group: person_group, person_id: add_cloud_person(person_group: person_group, face_id: face_id)['personId'])
    end
  
    def add_cloud_person(person_group:, face_id:)
      response = call_azure(
        endpoint_name: "persongroups/#{person_group.azure_id}/persons",
        request_body: "{\"name\": \"#{face_id}\"}",
        http_method: :post,
      )
      puts "Added azure person: #{response}"
      response
    end

    def cloud_person(person_group:, person_id:)
      response = call_azure(endpoint_name: "persongroups/#{person_group.azure_id}/persons/#{person_id}")
      puts "Get azure person: #{response}"
      response
    end

    def detect_faces(photo)
      uri = uri_setup(endpoint_name: "detect", request_params:  { 'returnFaceId' => 'true', 'returnFaceLandmarks' => 'false' })
      puts "detect faces"
      faces = call_azure(
        endpoint_name: "detect", 
        request_params: { 'returnFaceId' => 'true', 'returnFaceLandmarks' => 'false' }, 
        request_body: photo, 
        request_type: REQUEST_TYPE_OS,
        http_method: :post,
      )
      puts "detected_faces: #{faces}"
      faces.blank? ? [] : faces
    end

    def person_identities(person_group:, face_ids:)
      puts "person_group: #{person_group.azure_id}"
      response = call_azure(
        endpoint_name: "identify",
        request_body: "{
          \"personGroupId\": \"#{person_group.azure_id}\",
          \"faceIds\": #{face_ids}
        }",
        http_method: :post,
      )
      response.blank? ? [] : response
    end

    private

    def call_azure(endpoint_name:, request_params: {}, request_body: {}, request_type: REQUEST_TYPE_JSON, http_method: :get)
      uri = uri_setup(endpoint_name: endpoint_name, request_params: request_params)
      request = request_setup(request_uri: uri.request_uri, request_type: request_type, request_body: request_body, http_method: http_method)
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
      while RESPONSE_CODES[response.code] == code
        sleep(10)
        response = get_call_response(uri: uri, request: request)  
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

    def request_setup(request_uri:, request_type:, request_body:, http_method: :get)
      request = HTTP_METHODS[http_method].new(request_uri)
      request['Content-Type'] = "application/#{request_type}"
      request['Ocp-Apim-Subscription-Key'] = SUBSCRIPTION_KEY
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

    attr_reader :photos
  end
end