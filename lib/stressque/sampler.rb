module Stressque
  class Sampler
    attr_reader :harness, :injector
    attr_accessor :stat_handler, :sample_rate

    def initialize(harness, injector, sample_rate)
      @harness = harness
      @injector = injector
      @sample_rate = sample_rate
    end

    def current_stats
      [Time.now, harness.target_rate, injector.current_rate, injector.total_injections]
    end

    def stat_handler=(callable)
      @stat_handler = callable
    end

    def run
      while(true) do
        sleep(sample_rate.to_f)
        stat_handler.call(*current_stats)
      end
    end
  end
end
