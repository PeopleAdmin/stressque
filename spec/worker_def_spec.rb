require 'spec_helper'
require 'benchmark'

describe WorkerDef do
  let(:worker_def) {WorkerDef.new}
  before do
    worker_def.queue = :my_queue
    worker_def.class_name = :my_job
  end

  describe "#class_name" do
    it "should convert string to camelcase version" do
      worker_def.class_name.should == "MyJob"
    end

    it "should fail fast if the passed arg would not be valid class name" do
      expect{ worker_def.class_name=nil }.to raise_error
    end
  end

  describe "#runtime_min" do
    it "should default to 1" do
      worker_def.runtime_min.should == 1
    end
  end

  describe "#runtime_max" do
    it "should default to 1" do
      worker_def.runtime_max.should == 1
    end
  end

  describe "#weight" do
    it "should default to 1" do
      worker_def.weight.should == 1
    end
  end

  describe "#validate!" do
    it "should raise exception if queue is not present" do
      worker_def.queue = nil
      expect{worker_def.validate!}.to raise_error
    end

    it "should raise exception if @class_name is not present" do
      worker_def.instance_variable_set(:@class_name, nil)
      expect{worker_def.validate!}.to raise_error
    end

    it "should raise exception if runtime_min is not <= runtime_max" do
      worker_def.runtime_min = 2
      worker_def.runtime_max = 1
      expect{worker_def.validate!}.to raise_error
    end
  end

  describe "#to_job_class" do
    before {worker_def.runtime_max = 2}
    let(:job_class) {worker_def.to_job_class}

    it "should return a job class with a name matching the defs class_name" do
      job_class.should == MyJob
    end

    it "should return a job class with a @queue variable matching the defs queue" do
      job_class.instance_variable_get(:@queue).should == :my_queue
    end

    it "should return a job class with a @runtime_range var that is def.runtime_min..def.runtime_max" do
      job_class.instance_variable_get(:@runtime_range).should == (1..2)
    end

    it "should have a perform class method defined" do
      job_class.respond_to?(:perform).should == true
    end

    describe "#perform" do
      it "should take between runtime_min and runtime_max to perform" do
        job = job_class
        bm = Benchmark.measure {job.perform}
        (bm.real > worker_def.runtime_min).should == true
        (bm.real < worker_def.runtime_max).should == true
      end
    end
  end
end
