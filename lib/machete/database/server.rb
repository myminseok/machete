require 'uri'

module Machete
  class Database
    class Server
      IP_REGEXP = Regexp.new(/((25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)\.){3}(25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)/)

      def host
        output = `bosh vms`
        postgres_host_line = output.split("\n").grep(/postgres/).first
        IP_REGEXP.match(postgres_host_line).to_s
      end

      def port
        5524
      end

      def type
        'postgres'
      end
    end
  end
end
