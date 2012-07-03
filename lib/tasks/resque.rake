require 'resque/pool/tasks'

task "resque:setup" => :environment do
end

task "resque:pool:setup" do
  ActiveRecord::Base.connection.disconnect!
  Resque::Pool.after_prefork do |job|
    ActiveRecord::Base.establish_connection
  end
end