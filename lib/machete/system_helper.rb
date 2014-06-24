module Machete
  module SystemHelper
    def self.run_cmd(cmd, silent=false)
      Machete.logger.info "$ #{cmd}" unless silent
      result = `#{cmd}`
      @last_status = $?
      Machete.logger.info result unless silent
      result
    end

    def self.last_status
      @last_status
    end
  end
end
