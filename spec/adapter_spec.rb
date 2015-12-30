require 'helper'

describe Adapter do
  before do
    Adapter.definitions.clear
    Adapter.adapters.clear
  end

  after do
    Adapter.definitions.clear
    Adapter.adapters.clear
  end

  describe ".definitions" do
    it "defaults to empty hash" do
      Adapter.instance_variable_set("@definitions", nil)
      expect(Adapter.definitions).to eq({})
    end
  end

  describe ".define" do
    describe "with string name" do
      it "symbolizes string adapter names" do
        Adapter.define('memory', valid_module)
        expect(Adapter.definitions.keys).to include(:memory)
      end
    end

    describe "with module" do
      before do
        @mod = valid_module
        Adapter.define(:memory, mod)
      end
      let(:mod) { @mod }

      it "adds adapter to definitions" do
        expect(Adapter.definitions).to have_key(:memory)
        expect(Adapter.definitions[:memory]).to be_instance_of(Module)
      end

      it "includes the defaults" do
        Class.new do
          include Adapter.definitions[:memory]
        end.tap do |klass|
          expect(klass.new.respond_to?(:fetch)).to be(true)
          expect(klass.new.respond_to?(:key?)).to be(true)
          expect(klass.new.respond_to?(:read_multiple)).to be(true)
        end
      end

      [:read, :write, :delete, :clear].each do |method_name|
        it "raises error if #{method_name} is not defined in module" do
          mod.send(:undef_method, method_name)

          expect do
            Adapter.define(:memory, mod)
          end.to raise_error(Adapter::IncompleteAPI, "Missing methods needed to complete API (#{method_name})")
        end
      end
    end

    describe "with block" do
      before do
        Adapter.define(:memory) do
          def read(key)
            client[key]
          end

          def write(key, value)
            client[key] = value
          end

          def delete(key)
            client.delete(key)
          end

          def clear
            client.clear
          end
        end
      end

      it "adds adapter to definitions" do
        expect(Adapter.definitions).to have_key(:memory)
      end

      it "modularizes the block" do
        expect(Adapter.definitions[:memory]).to be_instance_of(Module)
      end
    end

    describe "with module and block" do
      before do
        Adapter.define(:memory, valid_module) do
          def clear
            raise 'Not Implemented'
          end
        end
      end

      it "includes block after module" do
        adapter = Adapter[:memory].new({})
        adapter.write('foo', 'bar')
        expect(adapter.read('foo')).to eq('bar')
        expect do
          adapter.clear
        end.to raise_error('Not Implemented')
      end
    end
  end

  describe "Redefining an adapter" do
    before do
      Adapter.define(:memory, valid_module)
      Adapter.define(:hash, valid_module)
      @memoized_memory = Adapter[:memory]
      @memoized_hash = Adapter[:hash]
      Adapter.define(:memory, valid_module)
    end

    it "unmemoizes adapter by name" do
      expect(Adapter[:memory]).not_to equal(@memoized_memory)
    end

    it "does not unmemoize other adapters" do
      expect(Adapter[:hash]).to equal(@memoized_hash)
    end
  end

  describe ".[]" do
    before do
      Adapter.define(:memory, valid_module)
    end

    it "returns adapter instance" do
      adapter = Adapter[:memory].new({})
      adapter.write('foo', 'bar')
      expect(adapter.read('foo')).to eq('bar')
      adapter.delete('foo')
      expect(adapter.read('foo')).to be_nil
      adapter.write('foo', 'bar')
      adapter.clear
      expect(adapter.read('foo')).to be_nil
    end

    it "raises error for undefined adapter" do
      expect do
        Adapter[:non_existant]
      end.to raise_error(Adapter::Undefined)
    end

    it "memoizes adapter by name" do
      expect(Adapter[:memory]).to equal(Adapter[:memory])
    end
  end

  describe "Adapter" do
    before do
      Adapter.define(:memory, valid_module)
      @client = {}
      @adapter = Adapter[:memory].new(@client)
    end
    let(:adapter) { @adapter }

    describe "#initialize" do
      it "works with options" do
        Adapter.define(:memory, valid_module)
        adapter = Adapter[:memory].new({}, :namespace => 'foo')
        expect(adapter.options[:namespace]).to eq('foo')
      end
    end

    describe "#name" do
      it "returns adapter name" do
        expect(adapter.name).to be(:memory)
      end
    end

    describe "#fetch" do
      it "returns value if key found" do
        adapter.write('foo', 'bar')
        expect(adapter.fetch('foo', 'baz')).to eq('bar')
      end

      it "returns default value if not key found" do
        expect(adapter.fetch('foo', 'baz')).to eq('baz')
      end

      describe "with block" do
        it "returns value if key found" do
          adapter.write('foo', 'bar')
          expect(adapter).not_to receive(:write)
          expect(adapter.fetch('foo') do
                      'baz'
                    end).to eq('bar')
        end

        it "returns default if key not found" do
          expect(adapter.fetch('foo', 'default')).to eq('default')
        end

        it "returns result of block if key not found" do
          expect(adapter.fetch('foo') do
                      'baz'
                    end).to eq('baz')
        end

        it "returns key if result of block writes key" do
          expect(adapter.fetch('foo', 'default') do
                      adapter.write('foo', 'write in block')
                    end).to eq('write in block')
        end

        it "yields key to block" do
          expect(adapter.fetch('foo') do |key|
                      key
                    end).to eq('foo')
        end
      end
    end

    describe "#key?" do
      it "returns true if key is set" do
        adapter.write('foo', 'bar')
        expect(adapter.key?('foo')).to be(true)
      end

      it "returns false if key is not set" do
        expect(adapter.key?('foo')).to be(false)
      end
    end

    describe "#eql?" do
      it "returns true if same name and client" do
        expect(adapter).to eql(Adapter[:memory].new({}))
      end

      it "returns false if different name" do
        Adapter.define(:hash, valid_module)
        expect(adapter).not_to eql(Adapter[:hash].new({}))
      end

      it "returns false if different client" do
        expect(adapter).not_to eql(Adapter[:memory].new(Object.new))
      end
    end

    describe "#==" do
      it "returns true if same name and client" do
        expect(adapter).to eq(Adapter[:memory].new({}))
      end

      it "returns false if different name" do
        Adapter.define(:hash, valid_module)
        expect(adapter).not_to eq(Adapter[:hash].new({}))
      end

      it "returns false if different client" do
        expect(adapter).not_to eq(Adapter[:memory].new(Object.new))
      end
    end
  end
end
