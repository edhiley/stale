

class Runner
  
  attr_accessor :documents
  
  def initialize(documents)
    @documents = documents
  end
  
  def run_threaded(worker_count)
    
    runners = []
    threads = []
    
    for i in 0..worker_count-1
      document_batch = slice(i, worker_count)
      runners << Runner.new(document_batch)
      threads << Thread.new{ runners[i].run;  }
    end
    
    threads.each{|t| t.join if t.alive? }
    
    @documents = []
     
    runners.each{|r|
      @documents << r.documents
    }
    
    @documents.flatten!
  end
  
  def slice(iterator, worker_count)
    batch_count = @documents.count.to_int / worker_count.to_int
    puts "batch count: #{batch_count}, document count: #{@documents.count}, worker count: #{worker_count}, returns #{(iterator*batch_count)}..#{((iterator*batch_count)+batch_count)-1}"
    @documents[(iterator*batch_count)..((iterator*batch_count)+batch_count)-1]
  end
  
  def run	
  
	resource_check_result = {
			"DateRan" => Time.now.strftime('%Y-%m-%dT%H:%M:%S%z'),
			"ResourceChecks" => [
			]
	}
	
	resource_checks = resource_check_result["ResourceChecks"]
	
@documents.each{ |d|
      
	resource_checks << {
		"Resource" => d["Id"],
		"UrlChecks" => []
	}
	
	url_checks = resource_checks.last["UrlChecks"]
      
      d["Urls"].each{|url|
        
        result = Checker.check_url(url)
        
        url_checks << {
          "Url" => result.url,
          "StatusCode" => result.status_code,
          "Message" => result.message
        }
      }
    }
    
    resource_check_result
  end

end