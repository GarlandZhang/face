require 'net/http'
uri = URI('https://westcentralus.api.cognitive.microsoft.com/face/v1.0/persongroups/person_group_garland/persons/6371a1fe-e502-49a6-adfe-b8f03461f06f/persistedFaces')
uri.query = URI.encode_www_form({
})

request = Net::HTTP::Post.new(uri.request_uri)
# Request headers
request['Content-Type'] = 'application/octet-stream'
# Request headers
request['Ocp-Apim-Subscription-Key'] = 'c48485623e4548bd958b7d526c535fb3'
# Request body
request.body = "{\"url\": \"https://scontent.fyyz1-1.fna.fbcdn.net/v/t1.15752-9/49017697_1847117408750742_7632980140028329984_n.jpg?_nc_cat=111&_nc_ht=scontent.fyyz1-1.fna&oh=67363ec2c5f516f812198f34c1441972&oe=5C8EC18B\"}"
response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
    http.request(request)
end

puts response.body
