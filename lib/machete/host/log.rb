module Machete
  class Host
    class Log
      attr_reader :host

      CAT_ACCESS_LOG = 'sudo cat /var/log/internet_access.log'
      REMOVE_ACCESS_LOG = 'sudo rm /var/log/internet_access.log'
      RESTART_SYSLOG = 'sudo restart rsyslog'

      def initialize(host)
        @host = host
      end

      def contents
        host.run CAT_ACCESS_LOG
      end

      def clear
        host.run REMOVE_ACCESS_LOG
        host.run RESTART_SYSLOG
      end
    end
  end
end