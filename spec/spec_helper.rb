require 'stressque'

RSpec.configure do |config|
  config.before(:each) do
    Resque.redis.select 15
    Resque.redis.flushdb
  end
end
