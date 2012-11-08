require 'adapter'

module Adapter
  module Memory
    def read(key)
      decode(client[key_for(key)])
    end

    def write(key, attributes)
      client[key_for(key)] = encode(attributes)
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
