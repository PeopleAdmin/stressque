require 'spec_helper'

describe Resque::Stress::Harness do
  describe "#validate!" do
    let(:harness) {Resque::Stress::Harness.new}

    it "should raise error if name is nil" do
      harness.name = nil
      expect {harness.validate!}.to raise_error
    end

    it "should raise error if name is empty" do
      harness.name = ''
      expect {harness.validate!}.to raise_error
    end
  end
end
