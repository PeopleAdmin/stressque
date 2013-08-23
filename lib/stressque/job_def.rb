require 'set'

module Stressque
  class JobDef
    attr_accessor :queue, :volume
    attr_writer :runtime_min, :runtime_max, :activity, :error_rate
    attr_reader :class_name

    def initialize
      runtime_min = 1
      runtime_max = 1
    end

    def class_name=(str)
      raise "Invalid class name: #{str}" if camelize(str).empty?
      @class_name = camelize(str)
    end

    def volume
      @volume ||= 1
    end

    def likelihood
      @likelihood ||= volume.to_f / queue.harness.total_volume
    end

    def runtime_min
      @runtime_min ||= 1
    end

    def runtime_max
      @runtime_max ||= 1
    end

    def activity
      @activity ||= 0.3
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
      unless @job_class
        @job_class = define_job_class
        # TODO this should work, but breaks in tests.  Why?
        # @job_class.freeze
      end
      @job_class
    end

    private
    def camelize(val)
      val.to_s.split('_').map(&:capitalize).join
    end

    def define_job_class
      class_def = <<-SRC
        class ::#{class_name}
          extend Stressque::Utils

          @queue = :#{queue.name}
          @runtime_range = #{runtime_min}.to_f..#{runtime_max}.to_f
          @error_rate = #{error_rate}
          @activity = #{activity}

          def self.perform
            active_sleep(normalized_rand(@runtime_range), @activity)
            raise "FAILED" if rand <= @error_rate
          end
        end
        #{class_name}
      SRC
      eval(class_def)
    end
  end
end
