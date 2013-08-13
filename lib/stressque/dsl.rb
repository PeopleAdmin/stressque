module Stressque
  module DSL
    def self.eval(source)
      ctx = GlobalContext.new
      ctx.instance_exec {eval(source)}
    end

    def self.eval_file(path)
      raise "File not found: #{path}" unless File.exists? path
      eval(File.read(path))
    end

    class GlobalContext
      attr_accessor :harness_context

      def harness(name, &block)
        self.harness_context = HarnessContext.new(name)
        self.harness_context.eval(&block)
      end
    end

    class KeywordContext
      def self.target_named(key)
        attr_accessor key.to_sym
        alias_method :target, key.to_sym
      end

      def eval(&block)
        self.instance_exec(&block)
        target.validate!
        target
      end
    end

    class HarnessContext < KeywordContext
      target_named :harness

      def initialize(name)
        self.harness = Harness.new
        self.harness.name = name
      end

      def queue(name, &block)
        queue_context = QueueDefContext.new(name, self.harness)
        harness.queues << queue_context.eval(&block)
      end

      def target_rate(val)
        harness.target_rate = val
      end
    end

    class QueueDefContext < KeywordContext
      target_named :queue

      def initialize(name, harness)
        self.queue = QueueDef.new
        self.queue.parent = harness
        self.queue.name = name
      end

      def job(class_name, &block)
        job_context = JobDefContext.new(self, class_name)
        queue.jobs << job_context.eval(&block)
      end
    end

    class JobDefContext < KeywordContext
      target_named :job

      def initialize(queue_context, class_name)
        self.job = JobDef.new
        self.job.queue = queue_context.queue
        self.job.class_name = class_name
      end

      def weight(val)
        job.weight = val
      end

      def runtime_min(val)
        job.runtime_min = val
      end

      def runtime_max(val)
        job.runtime_max = val
      end

      def error_rate(val)
        job.error_rate = val
      end
    end
  end
end
