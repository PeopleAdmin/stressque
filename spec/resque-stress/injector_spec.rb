require 'timeout'
require 'spec_helper'

Resque::Stress::Injector.send(:public, :mark_time)

describe Resque::Stress::Injector do
  let(:harness) {
    src = <<-SRC
      harness :my_rig do
        queue :my_queue do
          job :my_job do
            weight 1
          end
        end
      end
    SRC
    Resque::Stress::DSL.eval(src)
  }
  let(:injector) {Resque::Stress::Injector.new(harness)}
  describe "#run" do
    it "injects jobs into queue" do
      timeout(0.1) {injector.run} rescue nil
      Resque.queues.include?('my_queue').should == true
      Resque.pop("my_queue")["class"].should == MyJob.name
    end
  end

  describe "#total_injections" do
    it "should return all injections made" do
      injector.mark_time(1)
      injector.mark_time(2)
      injector.total_injections.should == 2
    end
  end

  describe "#last_100_timestamps" do
    it "should return the exact count if length < 100" do
      injector.mark_time(1)
      injector.mark_time(2)
      injector.last_100_timestamps.should == [1,2]
    end

    it "should truncate results to 100 if over that amount" do
      (0..125).each do |i|
        injector.mark_time(i)
      end
      injector.last_100_timestamps.size.should == 100
    end
  end

  describe "#current_rate" do
    it "should return 0 when nothing has been tracked" do
      injector.current_rate == 0
    end

    it "should return injections per second" do
      injector.mark_time(1.0)
      injector.mark_time(2.0)
      injector.current_rate.should == 2
    end
  end

  describe "#too_fast?" do
    it "should return true when current rate faster than target rate" do
      harness.target_rate = 1.0
      injector.mark_time(1.0)
      injector.mark_time(2.0)
      injector.too_fast?.should == true
    end

    it "should return false when current rate slower than target rate" do
      harness.target_rate = 3.0
      injector.mark_time(1.0)
      injector.mark_time(1.1)
      injector.too_fast?.should == false
    end

    it "should return false when current rate is equal to target rate" do
      harness.target_rate = 2.0
      injector.mark_time(1.0)
      injector.mark_time(2.0)
      injector.too_fast?.should == false
    end
  end
end
