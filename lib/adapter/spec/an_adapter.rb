shared_examples_for "an adapter" do
  it "can read the client" do
    adapter.client.should == client
  end

  let(:key)  { 'key' }
  let(:key2) { 'key2' }

  let(:attributes) {
    {
      :one   => 'one',
      :three => 'three',
    }
  }

  let(:attributes2) {
    {
      :two  => 'two',
      :four => 'four',
    }
  }

  describe "#read" do
    it "returns nil if key not available" do
      adapter.read(key).should be_nil
    end

    it "returns value if key available" do
      adapter.write(key, attributes)
      adapter.read(key).should eq(attributes)
    end
  end

  describe "#get" do
    it "returns nil if key not available" do
      adapter.get(key).should be_nil
    end

    it "returns value if key available" do
      adapter.write(key, attributes)
      adapter.get(key).should eq(attributes)
    end
  end

  describe "#[]" do
    it "returns nil if key not available" do
      adapter[key].should be_nil
    end

    it "returns value if key available" do
      adapter.write(key, attributes)
      adapter[key].should eq(attributes)
    end
  end

  describe "#read_multiple" do
    before do
      adapter.write(key, attributes)
      adapter.write(key2, attributes2)
    end

    it "returns Hash of keys and values" do
      adapter.read_multiple(key, key2).should eq({
        key  => attributes,
        key2 => attributes2,
      })
    end

    context "with mix of keys that are and are not available" do
      it "returns Hash of keys and values where unavailable keys are nil" do
        adapter.read_multiple(key, key2, 'foo', 'bar').should eq({
          key => attributes,
          key2 => attributes2,
          'foo' => nil,
          'bar' => nil,
        })
      end
    end
  end

  describe "#key?" do
    it "returns true if key available" do
      adapter.write(key, attributes)
      adapter.key?(key).should be_true
    end

    it "returns false if key not available" do
      adapter.key?(key).should be_false
    end
  end

  describe "#fetch" do
    context "with key not stored" do
      context "with default value" do
        it "returns default value" do
          adapter.fetch(key, {}).should eq({})
        end
      end

      context "with default block" do
        it "returns value of yielded block" do
          adapter.fetch(key) { |k| {} }.should eq({})
        end
      end
    end

    context "with key that is stored" do
      context "with default value" do
        it "returns key value instead of default" do
          adapter.write(key, attributes2)
          adapter.fetch(key, attributes).should eq(attributes2)
        end
      end

      context "with default block" do
        it "does not run the block" do
          adapter.write(key, attributes)
          unaltered = 'unaltered'
          adapter.fetch(key) { unaltered = 'altered' }
          unaltered.should eq('unaltered')
        end
      end
    end
  end

  describe "#write" do
    it "sets key to value" do
      adapter.write(key, attributes)
      adapter.read(key).should eq(attributes)
    end
  end

  describe "#set" do
    it "sets key to value" do
      adapter.set(key, attributes)
      adapter.read(key).should eq(attributes)
    end
  end

  describe "#[]=" do
    it "sets key to value" do
      adapter[key] = attributes
      adapter.read(key).should eq(attributes)
    end
  end

  describe "#delete" do
    context "when key available" do
      before do
        adapter.write(key, attributes)
        adapter.delete(key)
      end

      it "removes key" do
        adapter.key?(key).should be_false
      end
    end

    context "when key not available" do
      it "does not complain" do
        adapter.delete(key)
      end
    end
  end

  describe "#clear" do
    before do
      adapter[key] = attributes
      adapter[key2] = attributes2
      adapter.clear
    end

    it "removes all stored keys" do
      adapter.key?(key).should be_false
      adapter.key?(key2).should be_false
    end
  end
end
