require 'net/http'

uri = URI('https://westcentralus.api.cognitive.microsoft.com/face/v1.0/persongroups/banana_split/persons/4e37e1f7-4560-4e34-860e-7f4a772c1e03/persistedFaces')
uri.query = URI.encode_www_form({
})

request = Net::HTTP::Post.new(uri.request_uri)
# Request headers
request['Content-Type'] = 'application/json'
# Request headers
request['Ocp-Apim-Subscription-Key'] = 'c48485623e4548bd958b7d526c535fb3'
# Request body
request.body = "{\"url\": \"https://scontent.fyyz1-1.fna.fbcdn.net/v/t1.15752-9/48386470_507074706472301_5725127019713265664_n.jpg?_nc_cat=100&_nc_ht=scontent.fyyz1-1.fna&oh=e78a9f9b9ce4340f6e88169633f2554e&oe=5CD1B3EB\"}"
response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
    http.request(request)
end

puts response.body
