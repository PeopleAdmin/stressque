require 'spec_helper'
require 'benchmark'

describe Stressque::Utils do
  include Stressque::Utils

  def benchmark_and_verify(&block)
    (1..5).each do
      result = Benchmark.measure(&block)
      (result.real > 0.5).should == true
    end
  end

  describe "#hard_sleep" do
    it "should take > length to perform" do
      benchmark_and_verify {hard_sleep(0.5)}
    end
  end

  describe "#active_sleep" do
    it "should take > length to perform" do
      benchmark_and_verify {active_sleep(0.5, 0.3)}
    end
  end

  describe "#normalized_rand" do
    it "should give a number between the start/end of a range" do
      (1..1000).each do
        (normalized_rand(1..100) > 0).should == true
        (normalized_rand(1..100) < 100).should == true
      end
    end
  end
end
