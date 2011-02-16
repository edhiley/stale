require Dir.pwd + '/lib/checker'
require Dir.pwd + '/lib/runner'
require Dir.pwd + '/lib/utils'

raven_url_get = ENV["RAVEN_GET"] || "http://arms-local-r4.evidence.nhs.uk/linkchecker"
raven_put = ENV["RAVEN_PUT"] || "http://arms-local-r4.evidence.nhs.uk/linkchecker"
output_dir = File.join("output", Time.now.strftime("%Y_%m_%d-%H%M%S"))

to_process_path = File.join(output_dir, "to_process.js")
processed_path = File.join(output_dir, "processed.js")

task :default => ["stale:default"]

namespace :stale do
  
  desc "http GET from Raven of the arms urls to test"
  task :get_arms_document => [:create_directories] do
    Utils.get_arms_doc(raven_url_get, to_process_path)
  end
  
  task :create_directories do
    mkdir_p output_dir
  end
  
  task :default => [:process] do
    
  end

  desc "process the arms urls"    
  task :process => [:get_arms_document] do
    Utils.run_arms_doc(to_process_path, processed_path)
  end
  
  desc "send the arms urls"
  task :send do
    Utils.put_arms_doc(processed_path, raven_put)
  end 
 end