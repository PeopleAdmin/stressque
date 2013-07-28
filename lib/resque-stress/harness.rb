module Resque
  module Stress
    class Harness
      attr_accessor :name

      def queues
        @queues ||= []
      end

      def validate!
        raise 'Name not specified' if name.nil?
        raise 'Name cannot be empty' if name.to_s.empty?
      end
    end
  end
end
