module Machete
  module Host
    class Aws
      class DB < Struct.new(:host)
        def run(command)
          host.run "export PATH=/var/vcap/packages/postgres/bin:$PATH; #{command}", :postgres_z1
        end
      end
    end
  end
end

