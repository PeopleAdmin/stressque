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

      def all_jobs
        queues.map(&:jobs).flatten.sort &reverse_by_weight
      end

      private
      def reverse_by_weight
        lambda {|i, j| j.weight <=> i.weight}
      end
    end
  end
end
