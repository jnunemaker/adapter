require 'adapter/asserts'
require 'adapter/defaults'
require 'adapter/exceptions'

module Adapter
  extend self
  extend Asserts

  # Stores the definitions for each adapter by name
  def definitions
    @definitions ||= {}
  end

  def define(name, mod=nil, &block)
    definition_module = Module.new
    definition_module.send(:include, Defaults)
    definition_module.send(:include, mod) unless mod.nil?
    definition_module.send(:include, Module.new(&block)) if block_given?
    assert_valid_module(definition_module)
    adapters.delete(name.to_sym)
    definitions[name.to_sym] = definition_module
  end

  # Memoizes adapter instances based on their definitions
  def adapters
    @adapters ||= {}
  end

  def [](name)
    assert_valid_adapter(name)
    adapters[name.to_sym] ||= get_adapter_instance(name)
  end

  private
    def get_adapter_instance(name)
      Class.new do
        attr_reader :client, :options

        def initialize(client, options={})
          @client = client
          @options = options
        end

        include Adapter.definitions[name.to_sym]

        def eql?(other)
          self.class.eql?(other.class) && client == other.client
        end
        alias == eql?

        class_eval "def name; :#{name} end"
      end
    end
end
