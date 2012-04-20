module ModuleHelpers
  def valid_module
    Module.new do
      def read(key)
        decode(client[key_for(key)])
      end

      def write(key, value)
        client[key_for(key)] = encode(value)
      end

      def delete(key)
        client.delete(key_for(key))
      end

      def clear
        client.clear
      end
    end
  end
end
