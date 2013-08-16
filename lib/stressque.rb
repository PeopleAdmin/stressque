require 'resque'
require 'resque-clues'
require "stressque/version"
require 'stressque/utils'
require 'stressque/job_def'
require 'stressque/queue_def'
require 'stressque/harness'
require 'stressque/dsl'
require 'stressque/injector'
require 'stressque/sampler'
require 'stressque/railtie' if defined?(Rails::Railtie)

module Stressque
end
