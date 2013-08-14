module Stressque
  class Harness
    attr_accessor :name
    attr_writer :target_rate

    def freeze_classes!
      all_jobs.map(&:to_job_class).each {|job_class| job_class.freeze}
    end

    def queues
      @queues ||= []
    end

    def target_rate
      @target_rate ||= 100
    end

    def validate!
      raise 'Name not specified' if name.nil?
      raise 'Name cannot be empty' if name.to_s.empty?
    end

    def all_jobs
      queues.map(&:jobs).flatten.sort &reverse_by_volume
    end

    def total_volume
      all_jobs.inject(0) {|memo, job| memo += job.volume}
    end

    def pick_job_def(random=rand)
      tier = 0
      result = all_jobs.detect {|job|
        tier += job.likelihood
        random <= tier
      }
      result ||= all_jobs[-1]
    end

    private
    def reverse_by_volume
      lambda {|i, j| j.volume <=> i.volume}
    end
  end
end
