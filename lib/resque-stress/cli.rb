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
    end
  end
end
