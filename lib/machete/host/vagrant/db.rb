module Machete
  module Host
    class Vagrant
      class DB < Struct.new(:host)
        def run(command)
          SystemHelper.run_cmd(command)
        end
      end
    end
  end
end
