require 'net/http'
Net::HTTP.version_1_2
require 'uri'

class Checker
  
  def Checker.check_url(url, snooze_for = 0.2)
    self.check(url, snooze_for) if url != nil
  end
  
  private
  
  def self.check(url, snooze_for)
    puts " ... checking #{url}"
    sleep snooze_for
    
    begin
      uri = URI.parse(url)
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.head(uri.request_uri)
        case response
        when Net::HTTPOK, Net::HTTPRedirection then
          return ResourceResult.new(url, response.code, response.to_s)
        else
          return self.response_check(url)
        end
      end
    rescue TimeoutError => bang
      return ResourceResult.new(url, "timeout", bang)
    rescue SocketError => bang
      return ResourceResult.new(url, "error", bang)
    end
  end
  
  def self.response_check(url)
    response = Net::HTTP.get_response(URI.parse(url))
    return ResourceResult.new(url, response.code)
  end
  
end

class ResourceResult
  
  attr_accessor :url, :status_code, :message
  
  def initialize(url, status_code = "", message = "")
    @url, @status_code, @message = url, status_code, message
  end
  
end



