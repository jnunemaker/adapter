require 'rubygems'
require 'active_support'
require 'pathname'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)

require 'adapter/memory'

# Adapter.define also takes any combination of module and block.
#
# If module present, it is included. If block present, it is turned
# into a module and included. This means that including a module and
# a block allows overriding the module by defining methods in the block.
#
# In our case below, we simply override the memory adapter to create
# a new adapter that encodes/decodes using JSON instead of the default
# Marshal.load/dump. Also, important to note that this does not affect
# the memory adapter which still uses Marshal.
Adapter.define(:memory_json, Adapter::Memory) do
  def encode(value)
    ActiveSupport::JSON.encode(value)
  end

  def decode(value)
    ActiveSupport::JSON.decode(value)
  end
end

adapter = Adapter[:memory_json].new({})
adapter.clear

adapter.write('foo', 'bar' => 'baz')
# Encoded in adapter as json instead of being marshal'd
puts adapter.client['foo'].inspect # "{\"bar\":\"baz\"}"


adapter.client['foo'] = ActiveSupport::JSON.encode('chunky' => 'bacon')
# Decoded from adapter using json instead of being un-marshal'd
puts adapter.read('foo').inspect # {"chunky"=>"bacon"}
