require 'set'
require 'active_support/core_ext/string/inflections'

module Resque
  module Stress
    class JobDef
      attr_accessor :queue, :weight
      attr_writer :runtime_min, :runtime_max, :error_rate
      attr_reader :class_name

      def initialize
        runtime_min = 1
        runtime_max = 1
      end

      def class_name=(str)
        raise "Invalid class name: #{str}" if str.to_s.camelize.empty?
        @class_name = str.to_s.camelize
      end

      def weight
        @weight ||= 1
      end

      def likelihood
        @likelihood ||= weight.to_f / queue.harness.total_weight
      end

      def runtime_min
        @runtime_min ||= 1
      end

      def runtime_max
        @runtime_max ||= 1
      end

      def error_rate
        @error_rate ||= 0
      end

      def validate!
        raise "No queue specified" unless queue
        raise "Invalid class name: #{class_name}" unless class_name
        unless runtime_min <= runtime_max
          raise "runtime_min (#{runtime_min}) not <= runtime_max(#{runtime_max})"
        end
      end

      def to_job_class
        class_def = <<-SRC
          class ::#{class_name}
            extend Resque::Stress::Utils

            @queue = :#{queue.name}
            @runtime_range = #{runtime_min}.to_f..#{runtime_max}.to_f
            @error_rate = #{error_rate}

            def self.perform
              hard_sleep(normalized_rand(@runtime_range))
              raise "FAILED" if rand <= @error_rate
            end
          end
          #{class_name}
        SRC
        eval(class_def)
      end
    end
  end
end
