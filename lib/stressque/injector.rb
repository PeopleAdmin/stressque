module Stressque
  class Injector
    attr_reader :harness, :redis
    attr_accessor :running

    def initialize(harness)
      @harness = harness
      @redis = Resque.redis
    end

    def run
      reset!
      running = true
      mark_start
      while(running) do
        if too_fast?
          sleep(0.003)
          next
        end
        inject
      end
    end

    def total_injections
      redis.get(injections_key).to_i
    end

    def current_rate
      return 0 if elapsed_time == 0
      total_injections.to_f / elapsed_time
    end

    def too_fast?
      current_rate > harness.target_rate
    end

    private
    def reset!
      redis.del start_key
      redis.del injections_key
    end

    def inject
      klass = harness.pick_job_def.to_job_class
      Resque.enqueue klass
      redis.incr injections_key
    end

    def mark_start
      redis.set(start_key, current_time)
      sleep(1)
    end

    def start_time
      redis.get(start_key).to_i
    end

    def current_time
      redis.info.fetch("uptime_in_seconds").to_i
    end

    def elapsed_time
      current_time - start_time
    end

    def injections_key
      "stressque:#{harness.name}:injections"
    end

    def start_key
      "stressque:#{harness.name}:start"
    end
  end
end
