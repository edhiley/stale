require 'net/http'
require 'webmock/rspec'
require 'utils'

Net::HTTP.version_1_2


describe Utils do
  
  it "saves a file from raven" do 
    body = '{ "Results": [
      {
          "Id" : "docs/1",
          "Urls_ConvertToJson" : "true",
          "Urls" : ["http://1.com/a", "http://1.com/a"]
      },
      {
          "Id" : "docs/2",
          "Urls_ConvertToJson" : "true",
          "Urls" : ["http://1.com/a"]
      },
      {
          "Id" : "docs/3",
          "Urls_ConvertToJson" : "true",
          "Urls" : ["http://1.com/a", "http://1.com/a"]
      }]
    }'
    
    stub_request(:get, "http://raven/indexes/urls").
      with(:headers => {'Accept'=>'*/*'}).
      to_return(:status => 200, :body => body, :headers => {})
    
    Utils.get_arms_doc("http://raven/indexes/urls", "an_input_file")
    
    # check for file
    FileTest.exists?("an_input_file").should == true
  
  end

  it "runs arms file" do
    
    stub_request(:head, "http://1.com/a").
         with(:headers => {'Accept'=>'*/*'}).
         to_return(:status => 200, :body => "", :headers => {})
    
    # I've build a dependency here on the above test running first... - bad
    Utils.run_arms_doc("an_input_file", "a_processed_file")
    FileTest.exists?("a_processed_file").should == true
  end
  
  it "puts arms doc to raven" do
    stub_request(:put, "http://raven/documents/put").
      with(:body => "simple_content", 
           :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json'}).
      to_return(:status => 200, :body => "", :headers => {})
    
    
    Utils.put_arms_doc("spec/simple", "http://raven/documents/put")
  end
  
end