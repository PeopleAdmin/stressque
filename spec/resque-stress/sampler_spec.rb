require 'timeout'
require 'spec_helper'

describe Resque::Stress::Sampler do
  let(:harness) {double("harness")}
  let(:injector) {double("injector")}
  let(:sampler) {Resque::Stress::Sampler.new(harness, injector, 0.2)}

  before do
    allow(harness).to receive(:target_rate) {10}
    allow(injector).to receive(:current_rate) {9.9}
    allow(injector).to receive(:total_injections) {1000}
  end

  describe "#current_stats" do
    it "should return tuple of target rate, current rate and total injections" do
      target_rate, current_rate, total_injections = sampler.current_stats
      target_rate.should == 10
      current_rate.should == 9.9
      total_injections.should == 1000
    end
  end

  describe "#run" do
    it "should invoke the stat handler with data" do
      invoked = false
      sampler.stat_handler = proc {invoked = true}
      timeout(2.0) {sampler.run} rescue nil
      invoked.should == true
    end
  end
end
