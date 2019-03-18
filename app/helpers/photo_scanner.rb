class PhotoScanner

  URL = "https://westcentralus.api.cognitive.microsoft.com/face/v1.0/"
  SUBSCRIPTION_KEY = '34b4563891a147239c593cb83f6eca63'

  RESPONSE_CODES = { 429 => :limit_reached }

  REQUEST_TYPE_JSON = 'json'
  REQUEST_TYPE_OS = 'octet-stream'

  def initialize(photos)
      @photos = photos
  end

  def add_user_images
      return [] if photos.nil?
      user_images = []
      photos.each do |photo|
          faces = detect_faces(photo)
      end
  end

  private

  def detect_faces(photo)
    response = post_call_azure(
      endpoint_name: "detect", 
      request_params: { 'returnFaceId' => 'true', 'returnFaceLandmarks' => 'false' }, 
      request_body: photo.read, 
      request_type: REQUEST_TYPE_OS)
    if response.blank?
      puts "No faces detected!"
    else
      puts "Faces detected! Response: #{response}"
      response
    end
  end

  def post_call_azure(endpoint_name:, request_params: {}, request_body: {}, request_type: REQUEST_TYPE_JSON)    
    response = spam_call(
      uri: uri_setup(endpoint_name: endpoint_name, request_params: request_params), 
      request: request_setup(uri: uri, request_type: request_type, request_body: request_body), 
      code: :limit_reached
    )
    normalize_response(response.body)
  end

  def normalize_response(response_body)
    response_body.blank? "" : JSON.parse(response.body)
  end

  def spam_call(uri:, request:, code:)
    response = get_call_response(uri: uri, request: request)  
    while RESPONSE_CODES[response.code] == :code
      sleep(10)
      response = get_call_response(uri: uri, request: request)  
    end
    response
  end

  def uri_setup(endpoint_name:, request_params:)
    uri = URI(URL + end_point)
    uri.query = URI.encode_www_form(request_params)
    uri
  end

  def request_setup(uri:, request_type:, request_body:)
    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = "application/#{request_type}"
    request['Ocp-Apim-Subscription-Key'] = SUBSCRIPTION_KEY
    request.body = request_body.to_s
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