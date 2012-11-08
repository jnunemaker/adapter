shared_examples_for "an adapter" do
  it "can read the client" do
    adapter.client.should == client
  end

  let(:key)  { 'key' }
  let(:key2) { 'key2' }

  let(:unavailable_key)  { 'foo' }

  let(:attributes) {
    {
      'one'   => 'one',
      'three' => 'three',
    }
  }

  let(:attributes2) {
    {
      'two'  => 'two',
      'four' => 'four',
    }
  }

  describe "#read" do
    it "returns nil if key not available" do
      adapter.read(key).should be_nil
    end

    it "returns attributes if key available" do
      adapter.write(key, attributes)
      result = adapter.read(key)
      attributes.each do |column, value|
        result[column].should eq(value)
      end
    end
  end

  describe "#get" do
    it "returns nil if key not available" do
      adapter.get(key).should be_nil
    end

    it "returns attributes if key available" do
      adapter.write(key, attributes)
      result = adapter.get(key)
      attributes.each do |column, value|
        result[column].should eq(value)
      end
    end
  end

  describe "#[]" do
    it "returns nil if key not available" do
      adapter[key].should be_nil
    end

    it "returns attributes if key available" do
      adapter.write(key, attributes)
      result = adapter[key]
      attributes.each do |column, value|
        result[column].should eq(value)
      end
    end
  end

  describe "#read_multiple" do
    before do
      adapter.write(key, attributes)
      adapter.write(key2, attributes2)
    end

    it "returns Hash of keys and attributes" do
      result = adapter.read_multiple(key, key2)

      attributes.each do |column, value|
        result[key][column].should eq(value)
      end

      attributes2.each do |column, value|
        result[key2][column].should eq(value)
      end
    end

    context "with mix of keys that are and are not available" do
      it "returns Hash of keys and attributes where unavailable keys are nil" do
        result = adapter.read_multiple(key, key2, unavailable_key)

        attributes.each do |column, value|
          result[key][column].should eq(value)
        end

        attributes2.each do |column, value|
          result[key2][column].should eq(value)
        end

        result[unavailable_key].should be_nil
      end
    end
  end

  describe "#get_multiple" do
    before do
      adapter.write(key, attributes)
      adapter.write(key2, attributes2)
    end

    it "returns Hash of keys and attributes" do
      result = adapter.get_multiple(key, key2)

      attributes.each do |column, value|
        result[key][column].should eq(value)
      end

      attributes2.each do |column, value|
        result[key2][column].should eq(value)
      end
    end

    context "with mix of keys that are and are not available" do
      it "returns Hash of keys and attributes where unavailable keys are nil" do
        result = adapter.get_multiple(key, key2, unavailable_key)

        attributes.each do |column, value|
          result[key][column].should eq(value)
        end

        attributes2.each do |column, value|
          result[key2][column].should eq(value)
        end

        result[unavailable_key].should be_nil
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
    context "with key not available" do
      context "with default attributes" do
        it "returns default" do
          adapter.fetch(key, {}).should eq({})
        end
      end

      context "with default block" do
        it "returns value of yielded block" do
          adapter.fetch(key) { |k| {} }.should eq({})
        end
      end
    end

    context "with key that is available" do
      context "with default attributes" do
        it "returns result of read instead of default" do
          adapter.write(key, attributes2)
          result = adapter.fetch(key, attributes)
          attributes2.each do |column, value|
            result[column].should eq(value)
          end
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
    it "sets key to attributes" do
      adapter.write(key, attributes)
      result = adapter.read(key)
      attributes.each do |column, value|
        result[column].should eq(value)
      end
    end
  end

  describe "#set" do
    it "sets key to attributes" do
      adapter.set(key, attributes)
      result = adapter.read(key)
      attributes.each do |column, value|
        result[column].should eq(value)
      end
    end
  end

  describe "#[]=" do
    it "sets key to attributes" do
      adapter[key] = attributes
      result = adapter.read(key)
      attributes.each do |column, value|
        result[column].should eq(value)
      end
    end
  end

  describe "#delete" do
    context "when key available" do
      it "removes key" do
        adapter.write(key, attributes)
        adapter.key?(key).should be_true
        adapter.delete(key)
        adapter.key?(key).should be_false
      end
    end

    context "when key not available" do
      it "does not complain" do
        adapter.key?(key).should be_false
        adapter.delete(key)
        adapter.key?(key).should be_false
      end
    end
  end

  describe "#clear" do
    it "removes all available keys" do
      adapter.write(key, attributes)
      adapter.write(key2, attributes2)
      adapter.key?(key).should be_true
      adapter.key?(key2).should be_true
      adapter.clear
      adapter.key?(key).should be_false
      adapter.key?(key2).should be_false
    end
  end
end
