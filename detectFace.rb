require 'net/http'

uri = URI('https://westcentralus.api.cognitive.microsoft.com/face/v1.0/detect')
uri.query = URI.encode_www_form({
    # Request parameters
    'returnFaceId' => 'true',
    'returnFaceLandmarks' => 'false',
})

request = Net::HTTP::Post.new(uri.request_uri)
# Request headers
request['Content-Type'] = 'application/json'
# Request headers
request['Ocp-Apim-Subscription-Key'] = 'c48485623e4548bd958b7d526c535fb3'
# Request body
request.body = "{\"url\": \"https://scontent.fyyz1-1.fna.fbcdn.net/v/t1.15752-9/49090663_1843896832386609_2872147886143963136_n.jpg?_nc_cat=109&_nc_ht=scontent.fyyz1-1.fna&oh=ea651f0fad7d85b31f57cf0071c05685&oe=5C8D6209\"}"

response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
    http.request(request)
end

puts response.body


