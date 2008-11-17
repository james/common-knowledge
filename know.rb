require 'net/http'
require 'cgi'

response = Net::HTTP.post_form URI.parse('http://www.text118118.com/data/livefeed_test.aspx'), {"timePerQuestion"=>"50"}
knowledge = CGI.unescape(response.body.split('&').last.split('=').last).split("|").collect{ |t| t.split(";;") }

require 'rubygems'
require 'fastercsv'

csv = FasterCSV.open('questions.csv', "a")
knowledge.each do |question|
  csv << question
end
csv.close