require 'timeout'
require 'spec_helper'

Stressque::Injector.send(:public, :mark_start)
Stressque::Injector.send(:public, :inject)

describe Stressque::Injector do
  let(:harness) {
    src = <<-SRC
      harness :my_rig do
        queue :my_queue do
          job :my_job do
            volume 1
          end
        end
      end
    SRC
    Stressque::DSL.eval(src)
  }
  let(:injector) {Stressque::Injector.new(harness)}
  describe "#run" do
    it "injects jobs into queue" do
      timeout(1.1) {injector.run} rescue nil
      Resque.queues.include?('my_queue').should == true
      Resque.pop("my_queue")["class"].should == MyJob.name
    end
  end

  describe "#total_injections" do
    it "should return all injections made" do
      injector.inject
      injector.inject
      injector.total_injections.should == 2
    end
  end

  describe "#current_rate" do
    it "should return 0 when nothing has been tracked" do
      injector.current_rate == 0
    end

    it "should return injections per second" do
      injector.mark_start
      injector.inject
      injector.current_rate.should == 1.0
    end
  end

  describe "#too_fast?" do
    it "should return true when current rate faster than target rate" do
      harness.target_rate = 1.0
      injector.mark_start
      (1..100).each {injector.inject}
      sleep(1)
      injector.too_fast?.should == true
    end

    it "should return false when current rate slower than target rate" do
      harness.target_rate = 100.0
      injector.inject
      injector.inject
      injector.too_fast?.should == false
    end
  end
end
