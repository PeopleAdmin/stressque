require 'redis-namespace'

module Resque
  module Stress
    class Injector
      attr_reader :harness, :redis
      attr_accessor :running

      def initialize(harness)
        @harness = harness
        @redis = Redis::Namespace.new(:stress, Resque.redis)
      end

      def run
        running = true
        while(running) do
          next if too_fast?
          klass = harness.pick_job_def.to_job_class
          Resque.enqueue klass
          mark_time
        end
      end

      def last_100_timestamps
        # this could probably be made more efficient with sorted sets.
        redis.lrange(:timestamps, 0, 99).map(&:to_f).sort
      end

      def current_rate
        timestamps = last_100_timestamps
        return 0 if timestamps.nil? or timestamps.empty?
        time_span = timestamps[-1] - timestamps[0]
        return 0 if time_span == 0
        timestamps.size.to_f / time_span
      end

      def too_fast?
        current_rate > harness.target_rate
      end

      private
      def mark_time(now=Time.now.utc)
        redis.lpush(:timestamps, now.to_f.floor)
      end
    end
  end
end
