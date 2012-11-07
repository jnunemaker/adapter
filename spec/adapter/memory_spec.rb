require 'helper'
require 'adapter/memory'

describe "Memory adapter" do
  before do
    Adapter.define(:memory, Adapter::Memory)
    @client = {}
    @adapter = Adapter[:memory].new(@client)
    @adapter.clear
  end

  let(:adapter) { @adapter }
  let(:client)  { @client }

  it_should_behave_like 'an adapter'
end
