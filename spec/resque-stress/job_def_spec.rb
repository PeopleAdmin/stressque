require 'spec_helper'
require 'benchmark'

describe Resque::Stress::JobDef do
  let(:harness) {Resque::Stress::Harness.new}
  let(:queue) {Resque::Stress::QueueDef.new}
  let(:job_def) {Resque::Stress::JobDef.new}
  before do
    harness.queues << queue
    queue.parent = harness
    queue.name = :my_queue
    queue.jobs << job_def
    job_def.queue = queue
    job_def.class_name = :my_job
  end

  describe "#class_name" do
    it "should convert string to camelcase version" do
      job_def.class_name.should == "MyJob"
    end

    it "should fail fast if the passed arg would not be valid class name" do
      expect{ job_def.class_name=nil }.to raise_error
    end
  end

  describe "#runtime_min" do
    it "should default to 1" do
      job_def.runtime_min.should == 1
    end
  end

  describe "#runtime_max" do
    it "should default to 1" do
      job_def.runtime_max.should == 1
    end
  end

  describe "#weight" do
    it "should default to 1" do
      job_def.weight.should == 1
    end
  end

  describe "#likelihood" do
    it "should be equal to the weight divided by total weight of all jobs" do
      job_def.likelihood.should == 1
    end
  end

  describe "#error_rate" do
    it "should default to 0" do
      job_def.error_rate.should == 0
    end
  end

  describe "#validate!" do
    it "should raise exception if queue is not present" do
      job_def.queue = nil
      expect{job_def.validate!}.to raise_error
    end

    it "should raise exception if @class_name is not present" do
      job_def.instance_variable_set(:@class_name, nil)
      expect{job_def.validate!}.to raise_error
    end

    it "should raise exception if runtime_min is not <= runtime_max" do
      job_def.runtime_min = 2
      job_def.runtime_max = 1
      expect{job_def.validate!}.to raise_error
    end
  end

  describe "#to_job_class" do
    before {job_def.runtime_max = 2}
    let(:job_class) {job_def.to_job_class}

    context "without existing job classes" do
      it "should return a job class with a name matching the defs class_name" do
        job_class.should == MyJob
      end

      it "should return a job class with a @queue variable matching the defs queue" do
        job_class.instance_variable_get(:@queue).should == :my_queue
      end

      it "should return a job class with a @runtime_range var that is def.runtime_min..def.runtime_max" do
        job_class.instance_variable_get(:@runtime_range).should == (1..2)
      end

      it "should return a job class with an @error_rate var matching the defs error_rate" do
        job_class.instance_variable_get(:@error_rate).should == 0
      end

      it "should have a perform class method defined" do
        job_class.respond_to?(:perform).should == true
      end
    end

    context "with existing job class" do
      before do
        class MyJob
          @queue = :my_queue

          def self.perform
            "original"
          end
        end
        @original_class = MyJob
      end

      it "should modify the original class" do
        job_class.should == @original_class
      end

      it "should redefine the existing #perform behavior" do
        job_class.perform.should_not == "original"
      end
    end

    describe "#perform" do
      it "should take between runtime_min and runtime_max to perform" do
        job = job_class
        bm = Benchmark.measure {job.perform}
        (bm.real > job_def.runtime_min).should == true
        (bm.real < job_def.runtime_max).should == true
      end

      it "should raise errors according to the job defs error rate." do
        job_def.error_rate = 1.0
        expect{job_class.perform}.to raise_error
      end
    end
  end
end
