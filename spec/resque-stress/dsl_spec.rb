require 'spec_helper'

describe Resque::Stress::DSL do
  describe "#eval" do
    let(:source) {<<-SRC
      harness :my_rig do
        queue :my_queue do
          job :my_job do
            weight 10
            runtime_min 2
            runtime_max 4
            error_rate 0.1
          end
        end
      end
    SRC
    }

    let(:harness) {Resque::Stress::DSL.eval(source)}
    let(:queue) {harness.queues.first}
    let(:job) {queue.jobs.first}

    it "should populate the harness's name" do
      harness.name.should == :my_rig
    end

    it "should populate the harness's queues" do
      harness.queues.size.should == 1
    end

    it "should populate the queue's name" do
      queue.name.should == :my_queue
    end

    it "should populate the queue's jobs" do
      queue.jobs.size.should == 1
    end

    it "should populate the job's class_name" do
      job.class_name.should == "MyJob"
    end

    it "should populate the job's runtime_min" do
      job.runtime_min.should == 2
    end

    it "should populate the job's runtime_max" do
      job.runtime_max.should == 4
    end

    it "should populate the job's error_rate" do
      job.error_rate.should == 0.1
    end
  end
end
