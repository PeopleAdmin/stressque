require 'mixlib/cli'

module Resque
  module Stress
    class CLI
      include Mixlib::CLI

      option :config,
        short: "-c CONFIG",
        long:  "--config CONFIG",
        description: "The DSL config to use",
        required: true

      option :redis,
        short: "-r REDIS",
        long: "--redis REDIS",
        description: "The redis connection string",
        required: false
    end
  end
end
