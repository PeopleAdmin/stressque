module Resque
  module Stress
    class Injector
      attr_reader :harness, :redis
      attr_accessor :running

      def initialize(harness)
        @harness = harness
        @redis = Resque.redis
      end

      def run
        redis.flushdb
        running = true
        while(running) do
          if too_fast?
            sleep(0.003)
            next
          end
          klass = harness.pick_job_def.to_job_class
          Resque.enqueue klass
          mark_time
        end
      end

      def total_injections
        redis.llen(ts_key)
      end

      def current_rate
        duration = elapsed_time
        return 0 if duration == 0
        total_injections / duration
      end

      def too_fast?
        current_rate > harness.target_rate
      end

      private
      def mark_time(now=Time.now.utc)
        redis.rpush(ts_key, now.to_f.floor)
      end

      def elapsed_time
        earliest = redis.lrange(ts_key, 0, 0).first.to_f
        latest = Time.now.utc.to_f
        (earliest && latest) ? latest - earliest : 0
      end

      def ts_key
        "stressque:timestamps"
      end
    end
  end
end
