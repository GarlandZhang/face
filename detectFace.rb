require 'net/http'

uri = URI('https://westcentralus.api.cognitive.microsoft.com/face/v1.0/detect')
uri.query = URI.encode_www_form({
    # Request parameters
    'returnFaceId' => 'true',
    'returnFaceLandmarks' => 'true',
    'returnFaceAttributes' => "age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,occlusion,accessories,blur,exposure,noise"
})

request = Net::HTTP::Post.new(uri.request_uri)
# Request headers
request['Content-Type'] = 'application/json'
# Request headers
request['Ocp-Apim-Subscription-Key'] = 'c48485623e4548bd958b7d526c535fb3'
# Request body"}"
request.body = "{\"url\": \"https://scontent.fyyz1-1.fna.fbcdn.net/v/t1.15752-9/49609854_286855178848437_7937745023578144768_n.jpg?_nc_cat=110&_nc_ht=scontent.fyyz1-1.fna&oh=ceb47ef60831300989fb66c414699166&oe=5C9519BD\"}"

response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
    http.request(request)
end

puts response.body
