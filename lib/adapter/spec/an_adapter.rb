shared_examples_for "an adapter" do
  it "can read the client" do
    expect(adapter.client).to eq(client)
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
      expect(adapter.read(key)).to be_nil
    end

    it "returns attributes if key available" do
      adapter.write(key, attributes)
      result = adapter.read(key)
      attributes.each do |column, value|
        expect(result[column]).to eq(value)
      end
    end

    it "accepts options" do
      expect {
        adapter.read(key, :something => 'else')
      }.to_not raise_error
    end
  end

  describe "#read_multiple" do
    before do
      adapter.write(key, attributes)
      adapter.write(key2, attributes2)
    end

    it "returns Hash of keys and attributes" do
      result = adapter.read_multiple([key, key2])

      attributes.each do |column, value|
        expect(result[key][column]).to eq(value)
      end

      attributes2.each do |column, value|
        expect(result[key2][column]).to eq(value)
      end
    end

    context "with mix of keys that are and are not available" do
      it "returns Hash of keys and attributes where unavailable keys are nil" do
        result = adapter.read_multiple([key, key2, unavailable_key])

        attributes.each do |column, value|
          expect(result[key][column]).to eq(value)
        end

        attributes2.each do |column, value|
          expect(result[key2][column]).to eq(value)
        end

        expect(result[unavailable_key]).to be_nil
      end
    end

    it "accepts options" do
      expect {
        adapter.read_multiple([key], :something => 'else')
      }.to_not raise_error
    end
  end

  describe "#key?" do
    it "returns true if key available" do
      adapter.write(key, attributes)
      expect(adapter.key?(key)).to be(true)
    end

    it "returns false if key not available" do
      expect(adapter.key?(key)).to be(false)
    end

    it "accepts options" do
      expect {
        adapter.key?(key, :something => 'else')
      }.to_not raise_error
    end
  end

  describe "#fetch" do
    context "with key not available" do
      context "with default attributes" do
        it "returns default" do
          expect(adapter.fetch(key, {})).to eq({})
        end
      end

      context "with default block" do
        it "returns value of yielded block" do
          expect(adapter.fetch(key) { |k| {} }).to eq({})
        end
      end
    end

    context "with key that is available" do
      context "with default attributes" do
        it "returns result of read instead of default" do
          adapter.write(key, attributes2)
          result = adapter.fetch(key, attributes)
          attributes2.each do |column, value|
            expect(result[column]).to eq(value)
          end
        end
      end

      context "with default block" do
        it "does not run the block" do
          adapter.write(key, attributes)
          unaltered = 'unaltered'
          adapter.fetch(key) { unaltered = 'altered' }
          expect(unaltered).to eq('unaltered')
        end
      end
    end

    it "accepts options" do
      expect {
        adapter.fetch(key, true, :something => 'else')
      }.to_not raise_error
    end
  end

  describe "#write" do
    it "sets key to attributes" do
      adapter.write(key, attributes)
      result = adapter.read(key)
      attributes.each do |column, value|
        expect(result[column]).to eq(value)
      end
    end

    it "accepts options" do
      expect {
        adapter.write(key, attributes, :something => 'else')
      }.to_not raise_error
    end
  end

  describe "#delete" do
    context "when key available" do
      it "removes key" do
        adapter.write(key, attributes)
        expect(adapter.key?(key)).to be(true)
        adapter.delete(key)
        expect(adapter.key?(key)).to be(false)
      end
    end

    context "when key not available" do
      it "does not complain" do
        expect(adapter.key?(key)).to be(false)
        adapter.delete(key)
        expect(adapter.key?(key)).to be(false)
      end
    end

    it "accepts options" do
      expect {
        adapter.delete(key, :something => 'else')
      }.to_not raise_error
    end
  end

  describe "#clear" do
    it "removes all available keys" do
      adapter.write(key, attributes)
      adapter.write(key2, attributes2)
      expect(adapter.key?(key)).to be(true)
      expect(adapter.key?(key2)).to be(true)
      adapter.clear
      expect(adapter.key?(key)).to be(false)
      expect(adapter.key?(key2)).to be(false)
    end

    it "accepts options" do
      expect {
        adapter.clear(:something => 'else')
      }.to_not raise_error
    end
  end
end
