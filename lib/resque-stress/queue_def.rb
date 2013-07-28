module Resque
  module Stress
    class QueueDef
      attr_accessor :name
      attr_reader :jobs

      def jobs
        @jobs ||= []
      end

      def validate!
        raise "Queue name not specified" unless name
      end
    end
  end
end
