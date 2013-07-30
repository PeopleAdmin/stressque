require 'resque'

Resque.redis = 'localhost:6379:15'
Resque.redis.flushdb

require 'resque-stress'

load File.join(Rails.root, 'lib', 'jobs.rb')

path = File.join(Rails.root, 'config', 'stressque.dsl')
harness = Resque::Stress::DSL.eval_file(path)
harness.freeze_classes!
