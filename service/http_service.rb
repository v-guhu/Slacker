require 'httpclient'

clnt = HTTPClient.new
clnt.debug_dev = STDOUT
uri = 'http://lrm/LabRunReport.aspx?labrunid=1690748'
username = 'SEA\v-guhu'
password = 'Ep@198512257'
clnt.set_auth(nil, username, password)
res = clnt.get(uri)
puts res.content
#puts res.status
#p res.body
File.open("output.html", "w") do |file|
  file.puts res.content
end