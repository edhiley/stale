require 'net/http'
require 'uri'
require 'prettyprint'
require 'json'

Net::HTTP.version_1_2

class Utils
  
  def Utils.get_arms_doc(url, filename)
    
    Net::HTTP.get_response(URI.parse(url)) {|response|
      response.read_body do |str|   # read body now
        File.open(filename, 'w') {|f| f.write(str) }
      end
    }
  
  end
  
  def Utils.run_arms_doc(filename, output_filename)
  
    raise "the file #{output_filename} was not found" unless FileTest.exists?(filename)
    
    arms_doc = read_file(filename)
    arms_objects = JSON.parse(arms_doc)  
    result = Runner.new(arms_objects["Results"]).run

    File.open(output_filename, 'w') {|f| f.write(result.to_json) }
  end
  
  def Utils.put_arms_doc(path, url)
    
    uri = URI.parse(url)
    
    put_data = read_file(path)
    
    Net::HTTP.start(uri.host, uri.port) do |http|
	puts "sending document to ARMS..."
      headers = {'Accept'=>'appliction/json', "Content-Type" => "application/json"}
      response = http.send_request("PUT", uri.request_uri, put_data, headers)  
    p response
    end
    
  end
  
  private
  
  def Utils.read_file(path)
    file = ''
    File.open(path, 'r') { |f|
       f.each_line do |line|
         file += line
       end
     } 
     file
  end
  
end

