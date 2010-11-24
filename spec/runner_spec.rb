require 'runner'
require 'webmock/rspec'
require 'active_support'

describe Runner do
  
  before(:each) do
    
    @arms_docs = []
    
    (0..19).each{|i|
      @arms_docs << {
          "Id" => "docs/#{i}",
          "Urls_ConvertToJson" => "true",
          "Urls" => ["http://#{i}.com/a"]
      }
      
      stub_request(:any, "http://#{i}.com/a").
             with(:headers => {'Accept'=>'*/*'}).
             to_return(:status => 200, :body => "", :headers => {})
    }
  end
  
    
  context "loaded input urls" do
    
    it "runs 'real' data" do
      
        stub_request(:any, "http://1.com/a").
          with(:headers => {'Accept'=>'*/*'}).
          to_return(:status => 200, :body => "", :headers => {})
        
        input = { "Results" => [
          {
              "Id" => "docs/1",
              "Urls_ConvertToJson" => "true",
              "Urls" => ["http://1.com/a", "http://1.com/a"]
          },
          {
              "Id" => "docs/2",
              "Urls_ConvertToJson" => "true",
              "Urls" => ["http://1.com/a"]
          },
          {
              "Id" => "docs/3",
              "Urls_ConvertToJson" => "true",
              "Urls" => ["http://1.com/a", "http://1.com/a"]
          }]
        }
        
        result = Runner.new(input["Results"]).run
    
        result.count.should == 3
        result[0]["UrlChecks"].count.should == 2
        result[1]["UrlChecks"].count.should == 1
        
        # puts result.to_json
    end
    
    it "returns tested urls" do
      url_200 = "http://thisworksok.com/document1"
      url_404 = "http://thisdoesntworksowell.com/document1"
    
      runner = Runner.new([{
        "Id" => "doc/200",
        "Urls" => [url_200]
      },
      {
        "Id" => "doc/404",
        "Urls" => [url_404]
      }])
      
      stub_request(:head, url_200).
        with(:headers => {'Accept'=>'*/*'}).
        to_return(:status => 200, :body => "", :headers => {})
        
      stub_request(:any, url_404).
        with(:headers => {'Accept'=>'*/*'}).
        to_return(:status => 404, :body => "", :headers => {})

      result = runner.run
      
      result_200 = result.first
      result_404 = result[1]

      result_200["Id"].should == "doc/200"
      result_200["UrlChecks"].first["Url"].should == url_200
      result_200["UrlChecks"].first["StatusCode"].should == "200"
      
      result_404["Id"].should == "doc/404"
      result_404["UrlChecks"].first["Url"].should == url_404
      result_404["UrlChecks"].first["StatusCode"].should == "404"
      
      
      # puts result.to_json
      
    end
    
  end
  
  context "having threading" do
    
    # mock checker obj.
    
    it "slices first set of documents" do
      runner = Runner.new([].fill(1..1999) { "stuff" })
      runner.slice(0, 2).count.should == 1000
      runner.slice(1, 2).count.should == 1000
    end
    
    it "slices second set of documents" do
      runner = Runner.new([].fill(1..1999) { "stuff" })
      runner.slice(19, 20).count.should == 100
    end
    
    it "slices accurately" do
      count = 0
      runner = Runner.new([].fill(1..1999) { "stuff" })
      
      for i in 0..19
        count = count + runner.slice(i, 20).count
      end
      
      count.should == 2000
    end
    
    it "runs an uneven number" do
      runner = Runner.new([].fill(1..40) { "stuff" })
      
      runner.slice(0, 4).count.should == 10
      runner.slice(1, 4).count.should == 10
      runner.slice(2, 4).count.should == 10
      runner.slice(3, 4).count.should == 10
      runner.slice(4, 4).count.should == 1
    end
    
    it "runs threaded" do
      
      puts @arms_docs.count
      
      runner = Runner.new @arms_docs
      runner.run_threaded(10)
      
      runner.documents.count.should == @arms_docs.count
      
      runner.documents.first["Id"].should == @arms_docs.first["Id"]
      runner.documents.first["UrlChecks"].should_not be_nil
      runner.documents.first["UrlChecks"].should_not be_empty
      runner.documents.first["UrlChecks"].first["StatusCode"] == "200"
      
      runner.documents.last["Id"].should == @arms_docs.last["Id"]
      runner.documents.last["UrlChecks"].should_not be_nil
      runner.documents.last["UrlChecks"].should_not be_empty
      runner.documents.last["UrlChecks"].first["StatusCode"] == "200"
      runner.documents.last["UrlChecks"].first["Url"] == @arms_docs.last["Urls"].fetch(0)
      
      checked_urls = runner.documents.collect{|d|
        d["UrlChecks"].first["Url"]
      }
      
      checked_urls.count.should == @arms_docs.count
    end
    
  end
end

# load json object from file