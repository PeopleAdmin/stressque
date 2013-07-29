require 'resque-stress'

RSpec.configure do |config|
  config.before(:each) do
    Resque.redis.flushdb
  end
end
