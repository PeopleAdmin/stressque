module Resque
  module Stress
    class QueueDef
      attr_accessor :name, :parent
      attr_reader :jobs
      alias_method :harness, :parent

      def jobs
        @jobs ||= []
      end

      def validate!
        raise "Parent harness not specified" unless parent
        raise "Queue name not specified" unless name
      end
    end
  end
end
