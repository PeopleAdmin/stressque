require 'digest'
require 'fileutils'
require 'tmpdir'
require 'spec_helper'

describe Stressque::DSL do
  let(:source) {<<-SRC
    harness :my_rig do
      target_rate 1000

      queue :my_queue do
        job :my_job do
          volume 10
          runtime_min 2
          runtime_max 4
          error_rate 0.1
        end
      end
    end
  SRC
  }

  describe "#eval_file" do
    let(:path) {File.join(Dir.tmpdir, 'stressque.dsl')}
    before do
      File.write(path, source)
    end

    it "should parse file contents as a DSL" do
      harness = Stressque::DSL.eval_file(path)
      harness.kind_of?(Stressque::Harness).should == true
    end

    it "should raise an error if the file doesn't exist" do
      path = Digest::MD5.hexdigest(rand.to_s)
      expect{Stressque::DSL.eval_file(path)}.to raise_error
    end
  end

  describe "#eval" do
    let(:harness) {Stressque::DSL.eval(source)}
    let(:queue) {harness.queues.first}
    let(:job) {queue.jobs.first}

    it "should populate the harness's name" do
      harness.name.should == :my_rig
    end

    it "should populate the harness's queues" do
      harness.queues.size.should == 1
    end

    it "should populate the harness's target_rate" do
      harness.target_rate.should == 1000
    end

    it "should set the queue's parent as the harness" do
      queue.parent.should == harness
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
