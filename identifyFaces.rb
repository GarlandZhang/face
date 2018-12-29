require 'net/http'

uri = URI('https://westcentralus.api.cognitive.microsoft.com/face/v1.0/identify')
uri.query = URI.encode_www_form({
})

request = Net::HTTP::Post.new(uri.request_uri)
# Request headers
request['Content-Type'] = 'application/json'
# Request headers
request['Ocp-Apim-Subscription-Key'] = 'c48485623e4548bd958b7d526c535fb3'
# Request body
request.body = "{
    \"personGroupId\": \"banana_split\",
    \"faceIds\": [
        \"9b1f1049-0923-4248-9be3-34a68c03255c\"
    ]}"

response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
    http.request(request)
end

puts response.body
