require 'spec_helper'
require 'benchmark'

describe Utils do
  include Utils

  describe "#hard_sleep" do
    it "should take > length to perform" do
      (1..5).each do
        result = Benchmark.measure{hard_sleep(0.5)}
        (result.real > 0.5).should == true
      end
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
