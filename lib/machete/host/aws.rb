require 'bundler'

module Machete
  module Host
    class Aws
      START_FENCEPOST='---COMMAND START---'
      STOP_FENCEPOST='---COMMAND STOP---'

      def run command
        raise("BOSH_TARGET must be set") unless ENV['BOSH_TARGET']

        command_with_fenceposts = "echo \"#{START_FENCEPOST}\"; #{command}; echo \"#{STOP_FENCEPOST}\""
        bosh_command = "bosh ssh runner_z1 --gateway_user vcap --gateway_host #{ENV['BOSH_TARGET']} --default_password p '#{command_with_fenceposts}' 2>&1"

        result = ''
        Bundler.with_clean_env do
          result = `#{bosh_command}`
        end

        result.match(/#{START_FENCEPOST}\n(.*)#{STOP_FENCEPOST}/m)[1]
      end
    end
  end
end
