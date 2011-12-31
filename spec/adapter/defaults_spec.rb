require 'helper'

describe Adapter::Defaults do
  let(:mod) do
    Module.new.tap do |m|
      m.extend(Adapter::Defaults)
    end
  end

  describe "#key_for" do
    it "returns value for string" do
      mod.key_for('foo').should == 'foo'
    end

    it "returns string for symbol" do
      mod.key_for(:foo).should == 'foo'
    end

    it "marshals anything not a string or symbol" do
      mod.key_for({'testing' => 'this'}).should == Marshal.dump({'testing' => 'this'})
    end
  end

  describe "#encode" do
    it "marshals value" do
      mod.encode(nil).should == Marshal.dump(nil)
      mod.encode({'testing' => 'this'}).should == Marshal.dump({'testing' => 'this'})
    end
  end

  describe "#decode" do
    it "returns nil if nil" do
      mod.decode(nil).should be_nil
    end

    it "returns marshal load if not nil" do
      mod.decode(%Q(\004\b{\006\"\ftesting\"\tthis)).should == {'testing' => 'this'}
    end
  end
end