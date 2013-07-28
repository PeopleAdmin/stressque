require 'spec_helper'

describe Resque::Stress::QueueDef do
  describe "#validate!" do
    let(:queue_def) {Resque::Stress::QueueDef.new}
    before {queue_def.name = "test"}

    it "should raise exception if name not present" do
      queue_def.name = nil
      expect {queue_def.validate!}.to raise_error
    end
  end
end
