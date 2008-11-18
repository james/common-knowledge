require 'net/http'
require 'cgi'
require 'rubygems'
require 'fastercsv'

@pid_file = 'commonknowledge.pid'
@csv_file = 'questions.csv'
@interval = 60

def process!
  response = Net::HTTP.post_form URI.parse('http://www.text118118.com/data/livefeed_test.aspx'), {"timePerQuestion"=>"50"}
  knowledge = CGI.unescape(response.body.split('&').last.split('=').last).split("|").collect{ |t| t.split(";;") }
  csv = FasterCSV.open(@csv_file, "a")
  knowledge.each do |question|
    csv << question
  end
  csv.close
end

def daemonize!
  if File.exists?(@pid_file)
    puts 'pid already exists...start failed'
    return
  end
  
  pid = fork do
    
    Signal.trap 'TERM' do
      File.delete(@pid_file)
    end
    
    loop do
      process!
      sleep @interval
    end
    
  end

  File.open(@pid_file, 'w') { |file| file.write pid }
  
  Process.detach(pid)
  
  puts "Started daemon..."
end

daemonize!