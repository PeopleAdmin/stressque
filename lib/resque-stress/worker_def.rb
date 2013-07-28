require 'set'
require 'active_support/core_ext/string/inflections'

class WorkerDef
  attr_accessor :queue, :weight
  attr_writer :runtime_min, :runtime_max
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

  def runtime_min
    @runtime_min ||= 1
  end

  def runtime_max
    @runtime_max ||= 1
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
        extend Utils

        @queue = :#{queue.to_s}
        @runtime_range = #{runtime_min}.to_f..#{runtime_max}.to_f

        def self.perform
          hard_sleep(normalized_rand(@runtime_range))
        end
      end
      #{class_name}
    SRC
    eval(class_def)
  end
end