require 'checker'
require 'webmock/rspec'

describe Checker do
  context "checking urls" do
    it "returns false for broken url" do
      stub_request(:head, 'http://oiuoiu-oiuoiu-eeee-oiukjhkj.com/').to_raise(SocketError)
      
      result = Checker.check_url("http://oiuoiu-oiuoiu-eeee-oiukjhkj.com")
      result.status_code.should == "error"
      result.url.should == "http://oiuoiu-oiuoiu-eeee-oiukjhkj.com"
    end
    
    it "reports timeouts" do
      stub_request(:any, 'http://funkyslowdoc.com/imreallyslow').to_timeout
      
      result = Checker.check_url("http://funkyslowdoc.com/imreallyslow")
      result.status_code.should == "timeout"
      result.url.should == "http://funkyslowdoc.com/imreallyslow"
    end

    it "returns true for working url" do
      stub_request(:head, "http://www.google.co.uk/").
        with(:headers => {'Accept'=>'*/*'}).
        to_return(:status => 200, :body => "", :headers => {})
      
      result = Checker.check_url("http://www.google.co.uk")
      result.status_code.should == "200"
      result.url.should == "http://www.google.co.uk"
    end

    it "reports redirects" do
      stub_request(:head, "http://www.google.com/").
        with(:headers => {'Accept'=>'*/*'}).
        to_return(:status => 302, :body => "", :headers => {})
      
      result = Checker.check_url("http://www.google.com")
      result.status_code.should == "302"
      result.url.should == "http://www.google.com"
    end
  
    it "reports not found" do
      stub_request(:head, "http://www.google.com/stuff_that_dont_exist.html").
        with(:headers => {'Accept'=>'*/*'}).
        to_return(:status => 404, :body => "", :headers => {})

      stub_request(:get, "http://www.google.com/stuff_that_dont_exist.html").
        with(:headers => {'Accept'=>'*/*'}).
        to_return(:status => 404, :body => "", :headers => {})

      result = Checker.check_url("http://www.google.com/stuff_that_dont_exist.html")
      result.status_code.should == "404"
      result.url.should == "http://www.google.com/stuff_that_dont_exist.html"      
    end
  
    it "reports status, where doesn't support head" do
      stub_request(:head, "http://www.amazon.co.uk/").
        with(:headers => {'Accept'=>'*/*'}).
        to_return(:status => 500, :body => "", :headers => {}) # TODO: reports invalid head request
      
      stub_request(:get, "http://www.amazon.co.uk/").
        with(:headers => {'Accept'=>'*/*'}).
        to_return(:status => 200, :body => "", :headers => {}) # TODO: reports invalid head request
      
      result = Checker.check_url("http://www.amazon.co.uk")
      result.status_code.should == "200"
      result.url.should == "http://www.amazon.co.uk"
    end

  end
end

describe ResourceResult, "#initialize" do
  it "creates" do
    resource = ResourceResult.new("http://test.com", "200", "message")
    resource.url.should == "http://test.com"
    resource.status_code.should == "200"
    resource.message.should == "message"
  end
end