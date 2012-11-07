require 'helper'

describe Adapter::Defaults do
  let(:mod) do
    Module.new.tap do |m|
      m.extend(Adapter::Defaults)
    end
  end

  describe "#key_for" do
    it "returns whatever is passed to it" do
      [nil, 'foo', :foo, {:foo => 'bar'}].each do |key|
        mod.key_for(key).should be(key)
      end
    end
  end

  describe "#encode" do
    it "returns whatever is passed to it" do
      [nil, 'foo', :foo, {:foo => 'bar'}].each do |value|
        mod.encode(value).should be(value)
      end
    end
  end

  describe "#decode" do
    it "returns whatever is passed to it" do
      [nil, 'foo', :foo, {:foo => 'bar'}].each do |value|
        mod.decode(value).should be(value)
      end
    end
  end
end
