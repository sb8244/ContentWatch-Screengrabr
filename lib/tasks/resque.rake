require 'resque/tasks'

# load the Rails app all the time
namespace :resque do
  puts "Loading Rails environment for Resque"
  task :setup => :environment do
    SeleniumFirefoxPool.instance
  end
end