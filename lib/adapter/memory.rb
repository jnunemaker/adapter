require 'adapter'

module Adapter
  module Memory
    def read(key)
      decode(client[key_for(key)])
    end

    def write(key, value)
      client[key_for(key)] = encode(value)
    end

    def delete(key)
      decode(client.delete(key_for(key)))
    end

    def clear
      client.clear
    end
  end
end

Adapter.define(:memory, Adapter::Memory)
