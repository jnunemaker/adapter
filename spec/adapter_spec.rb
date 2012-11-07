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
      Adapter.definitions.should == {}
    end
  end

  describe ".define" do
    describe "with string name" do
      it "symbolizes string adapter names" do
        Adapter.define('memory', valid_module)
        Adapter.definitions.keys.should include(:memory)
      end
    end

    describe "with module" do
      before do
        @mod = valid_module
        Adapter.define(:memory, mod)
      end
      let(:mod) { @mod }

      it "adds adapter to definitions" do
        Adapter.definitions.should have_key(:memory)
        Adapter.definitions[:memory].should be_instance_of(Module)
      end

      it "includes the defaults" do
        Class.new do
          include Adapter.definitions[:memory]
        end.tap do |klass|
          klass.new.respond_to?(:fetch).should be_true
          klass.new.respond_to?(:key_for, true).should be_true
          klass.new.respond_to?(:encode, true).should be_true
          klass.new.respond_to?(:decode, true).should be_true
        end
      end

      [:read, :write, :delete, :clear].each do |method_name|
        it "raises error if #{method_name} is not defined in module" do
          mod.send(:undef_method, method_name)

          lambda do
            Adapter.define(:memory, mod)
          end.should raise_error(Adapter::IncompleteAPI, "Missing methods needed to complete API (#{method_name})")
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
        Adapter.definitions.should have_key(:memory)
      end

      it "modularizes the block" do
        Adapter.definitions[:memory].should be_instance_of(Module)
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
        adapter.read('foo').should == 'bar'
        lambda do
          adapter.clear
        end.should raise_error('Not Implemented')
      end
    end
  end

  describe "Overriding encode/decode" do
    before do
      Adapter.define(:memory_json, valid_module) do
        def encode(value)
          'encoded'
        end

        def decode(value)
          'decoded'
        end
      end
    end
    let(:adapter) { Adapter[:memory_json].new({}) }

    it "encodes correctly" do
      hash = {'foo' => 'bar'}
      adapter.write('foo', hash)
      adapter.client['foo'].should == 'encoded'
    end

    it "decodes correctly" do
      hash = {'foo' => 'bar'}
      adapter.client['foo'] = hash
      adapter.read('foo').should == 'decoded'
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
      Adapter[:memory].should_not equal(@memoized_memory)
    end

    it "does not unmemoize other adapters" do
      Adapter[:hash].should equal(@memoized_hash)
    end
  end

  describe ".[]" do
    before do
      Adapter.define(:memory, valid_module)
    end

    it "returns adapter instance" do
      adapter = Adapter[:memory].new({})
      adapter.write('foo', 'bar')
      adapter.read('foo').should == 'bar'
      adapter.delete('foo')
      adapter.read('foo').should be_nil
      adapter.write('foo', 'bar')
      adapter.clear
      adapter.read('foo').should be_nil
    end

    it "raises error for undefined adapter" do
      lambda do
        Adapter[:non_existant]
      end.should raise_error(Adapter::Undefined)
    end

    it "memoizes adapter by name" do
      Adapter[:memory].should equal(Adapter[:memory])
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
        adapter.options[:namespace].should == 'foo'
      end
    end

    describe "#name" do
      it "returns adapter name" do
        adapter.name.should be(:memory)
      end
    end

    describe "#fetch" do
      it "returns value if key found" do
        adapter.write('foo', 'bar')
        adapter.fetch('foo', 'baz').should == 'bar'
      end

      it "returns default value if not key found" do
        adapter.fetch('foo', 'baz').should == 'baz'
      end

      describe "with block" do
        it "returns value if key found" do
          adapter.write('foo', 'bar')
          adapter.should_not_receive(:write)
          adapter.fetch('foo') do
            'baz'
          end.should == 'bar'
        end

        it "returns default if key not found" do
          adapter.fetch('foo', 'default').should == 'default'
        end

        it "returns result of block if key not found" do
          adapter.fetch('foo') do
            'baz'
          end.should == 'baz'
        end

        it "returns key if result of block writes key" do
          adapter.fetch('foo', 'default') do
            adapter.write('foo', 'write in block')
          end.should == 'write in block'
        end

        it "yields key to block" do
          adapter.fetch('foo') do |key|
            key
          end.should == 'foo'
        end
      end
    end

    describe "#key?" do
      it "returns true if key is set" do
        adapter.write('foo', 'bar')
        adapter.key?('foo').should be_true
      end

      it "returns false if key is not set" do
        adapter.key?('foo').should be_false
      end
    end

    describe "#[]" do
      it "is aliased to read" do
        adapter.write('foo', 'bar')
        adapter['foo'].should == 'bar'
      end
    end

    describe "#get" do
      it "is aliased to read" do
        adapter.write('foo', 'bar')
        adapter.get('foo').should == 'bar'
      end
    end

    describe "#[]=" do
      it "is aliased to write" do
        adapter.read('foo').should be_nil
        adapter['foo'] = 'bar'
        adapter.read('foo').should == 'bar'
      end
    end

    describe "#[]=" do
      it "is aliased to write" do
        adapter.read('foo').should be_nil
        adapter.set('foo', 'bar')
        adapter.read('foo').should == 'bar'
      end
    end

    describe "#eql?" do
      it "returns true if same name and client" do
        adapter.should eql(Adapter[:memory].new({}))
      end

      it "returns false if different name" do
        Adapter.define(:hash, valid_module)
        adapter.should_not eql(Adapter[:hash].new({}))
      end

      it "returns false if different client" do
        adapter.should_not eql(Adapter[:memory].new(Object.new))
      end
    end

    describe "#==" do
      it "returns true if same name and client" do
        adapter.should == Adapter[:memory].new({})
      end

      it "returns false if different name" do
        Adapter.define(:hash, valid_module)
        adapter.should_not == Adapter[:hash].new({})
      end

      it "returns false if different client" do
        adapter.should_not == Adapter[:memory].new(Object.new)
      end
    end
  end
end
