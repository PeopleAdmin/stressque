require 'spec_helper'

describe Stressque::Harness do
  let(:harness) {Stressque::Harness.new}
  describe "#validate!" do
    it "should raise error if name is nil" do
      harness.name = nil
      expect {harness.validate!}.to raise_error
    end

    it "should raise error if name is empty" do
      harness.name = ''
      expect {harness.validate!}.to raise_error
    end
  end

  context "aggregate ops" do
    let(:queue1) {Stressque::QueueDef.new}
    let(:queue2) {Stressque::QueueDef.new}
    let(:job1) {Stressque::JobDef.new} 
    let(:job2) {Stressque::JobDef.new} 
    let(:job3) {Stressque::JobDef.new} 

    before do
      queue1.name = 'queue1'
      queue1.jobs << job1
      job1.queue = queue1
      queue1.jobs << job3
      job3.queue = queue1

      queue2.name = 'queue2'
      queue2.jobs << job2
      job2.queue = queue2

      job1.volume = 1
      job2.volume = 3
      job3.volume = 2

      harness.queues << queue1
      queue1.parent = harness
      harness.queues << queue2
      queue2.parent = harness
    end

    describe "#all_jobs" do
      it "should contain jobs from all queues" do
        result = Set.new(harness.all_jobs)
        result.should == Set.new([job1, job2, job3])
      end

      it "should have jobs sorted according to volume" do
        harness.all_jobs.should == [job2, job3, job1]
      end
    end

    describe "#total_volume" do
      it "should evaluate to the sum of all job volume" do
        expected = job1.volume + job2.volume + job3.volume
        harness.total_volume.should == expected
      end
    end

    describe "#job_for_roll" do
      it "should correctly pick job defs according to volume" do
        harness.pick_job_def(0.1).should == job2
        harness.pick_job_def(0.2).should == job2
        harness.pick_job_def(0.3).should == job2
        harness.pick_job_def(0.4).should == job2
        harness.pick_job_def(0.5).should == job2
        harness.pick_job_def(0.6).should == job3
        harness.pick_job_def(0.7).should == job3
        harness.pick_job_def(0.8).should == job3
        harness.pick_job_def(0.9).should == job1
      end

      it "should pick most likely job for any arg < 0" do
        harness.pick_job_def(-1).should == job2
      end

      it "should pick least likely job for any arg >= 1" do
        harness.pick_job_def(1.0).should == job1
      end
    end
  end
end
